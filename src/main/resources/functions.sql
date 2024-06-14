-- Function 3.4
CREATE OR REPLACE FUNCTION average_rating(p_container_id int) return float
    IS
    v_result float;
BEGIN
    SELECT AVG(RATING.VALUE) into v_result from RATING where RATING.CONTAINER_ID = p_container_id;

    return v_result;
END;

-- Function 7.1
CREATE OR REPLACE FUNCTION create_song(p_user_id int,
                                       p_title Song.title%type,
                                       p_duration Song.duration%type,
                                       p_release_date Song.release_date%type,
                                       p_description Song.description%type,
                                       p_image_filepath Song.image_filepath%type)
    return SONG.id%type
AS
    v_container_id CONTAINER.id%type;
    v_now          TIMESTAMP;
    v_song_id      Song.id%type;
BEGIN
    v_now := CURRENT_TIMESTAMP;

    INSERT INTO container VALUES (DEFAULT) RETURNING id INTO v_container_id;

    INSERT INTO song (title, description, release_date, duration, container_id, image_filepath)
    VALUES (p_title, p_description, p_release_date, p_duration, v_container_id, p_image_filepath)
    RETURNING id INTO v_song_id;

    INSERT INTO song_history (song_id, new_title, new_description, new_duration, new_release_date, new_image_filepath, user_id)
    VALUES (v_song_id, p_title, p_description, p_duration, p_release_date, p_image_filepath, p_user_id);
    COMMIT;
    return v_song_id;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        return null;
END;

-- Function 7.2
CREATE OR REPLACE FUNCTION search_songs(
    p_keyword IN Song.title%type,
    p_min_rating IN RATING.value%type,
    p_max_rating IN RATING.value%type,
    p_min_number_of_comments IN int,
    p_interpret IN INTERPRET.NAME%type,
    p_genre IN GENRE.NAME%type,
    p_min_duration IN SONG.duration%type,
    p_max_duration IN SONG.duration%type,
    p_created_before IN SONG.CREATED%type,
    p_created_after IN SONG.CREATED%type,
    p_released_before IN SONG.RELEASE_DATE%type,
    p_released_after IN SONG.RELEASE_DATE%type,
    p_order_by IN string
)
    return SYS_REFCURSOR
    IS
    songs Sys_Refcursor;
    invalid_range EXCEPTION;
    v_min_rating             RATING.value%type;
    v_max_rating             RATING.value%type;
    v_min_number_of_comments INTEGER;
    v_min_duration           SONG.duration%type;
    v_max_duration           SONG.duration%type;

BEGIN
    v_min_rating := COALESCE(p_min_rating, 0);
    v_max_rating := COALESCE(p_max_rating, 5);
    v_min_number_of_comments := COALESCE(p_min_number_of_comments, 0);
    v_min_duration := COALESCE(p_min_duration, 0);
    v_max_duration := COALESCE(p_max_duration, 99999999);


    if (0 > v_min_rating) or (v_min_rating > v_max_rating) or (v_max_rating > 5) then
        raise invalid_range;
    elsif (v_min_number_of_comments IS NOT NULL) and (v_min_number_of_comments < 0) then
        raise invalid_range;
    elsif (0 > v_min_duration) or (v_min_duration > v_max_duration) or (v_max_duration < 0) then
        raise invalid_range;
    end if;

    OPEN songs FOR
        SELECT *
        FROM song
                 JOIN container ON container.id = song.container_id
        WHERE (p_keyword IS NULL OR (song.title LIKE '%' || p_keyword || '%'))
          and (p_min_rating IS NULL OR (p_min_rating <= average_rating(container.id)))
          and (p_max_rating IS NULL OR (p_max_rating >= average_rating(container.id)))
          and (p_min_number_of_comments IS NULL OR (p_min_number_of_comments <= (SELECT COUNT(*)
                                                                                 FROM "COMMENT"
                                                                                 WHERE "COMMENT".container_id = container.id)))
          and (p_interpret IS NULL OR (EXISTS(SELECT *
                                              FROM interpret_song is_
                                                       JOIN interpret on interpret.id = is_.interpret_id
                                              WHERE is_.song_id = song.id
                                                and interpret.name = p_interpret)))
          and (p_genre IS NULL OR (EXISTS(SELECT *
                                          FROM container_genre cg
                                                   JOIN genre on genre.id = cg.genre_id
                                          WHERE cg.container_id = container.id
                                            AND genre.name = p_genre)))
          and (p_min_duration IS NULL OR (p_min_duration <= song.duration))
          and (p_max_duration IS NULL OR (p_max_duration >= song.duration))
          and (p_created_before IS NULL OR (p_created_before <= song.CREATED))
          and (p_created_after IS NULL OR (p_created_after >= song.CREATED))
          and (p_released_before IS NULL OR (p_released_before <= song.RELEASE_DATE))
          and (p_released_after IS NULL OR (p_released_after >= song.RELEASE_DATE))
        ORDER BY (CASE WHEN p_order_by = 'title' THEN song.title END),
                 (CASE
                      WHEN p_order_by = 'rating' THEN
                          average_rating(container.id) END) DESC,
                 (CASE WHEN p_order_by = 'duration' THEN song.duration END) DESC,
                 (CASE WHEN p_order_by = 'created' THEN song.created END) DESC,
                 (CASE
                      WHEN p_order_by = 'release_date' THEN
                          song.release_date END) DESC;


    return songs;
exception
    when others then
        raise;
END;

-- Function 7.3
CREATE OR REPLACE PROCEDURE get_songs_by_interpret_id(p_interpret_id IN INTERPRET.id%type, songs OUT SYS_REFCURSOR)
    IS
BEGIN
    OPEN songs FOR
        SELECT *
        FROM interpret_song
                 JOIN song ON song.id = interpret_song.song_id
        WHERE interpret_song.interpret_id = p_interpret_id;
END;

-- Function 7.4
CREATE OR REPLACE PROCEDURE get_songs_by_genre_id(p_genre_id IN GENRE.id%type, songs OUT SYS_REFCURSOR)
    IS
BEGIN
    OPEN songs FOR
        SELECT *
        FROM container_genre gs
                 JOIN song ON song.container_id = gs.CONTAINER_ID
        WHERE gs.genre_id = p_genre_id;
END;

-- Function 7.6
CREATE OR REPLACE PROCEDURE update_song(p_user_id int,
                                        p_song_id int,
                                        p_title Song.title%type,
                                        p_duration Song.duration%type,
                                        p_release_date Song.release_date%type,
                                        p_description Song.description%type,
                                        p_image_filepath Song.image_filepath%type)
    IS
    v_song_old Song%ROWTYPE;
    v_now      TIMESTAMP;

BEGIN
    v_now := CURRENT_TIMESTAMP;
    SELECT * into v_song_old FROM song WHERE song.id = p_song_id;

    INSERT INTO song_history(song_id, modified_at, new_title, new_description, new_duration, new_release_date,
                             new_image_filepath, user_id)
    VALUES (p_song_id,
            v_now,
            COALESCE(p_title, v_song_old.title),
            COALESCE(p_description, v_song_old.description),
            COALESCE(p_duration, v_song_old.duration),
            COALESCE(p_release_date, v_song_old.release_date),
            COALESCE(p_image_filepath, v_song_old.image_filepath),
            p_user_id);

    UPDATE song
    SET title          = COALESCE(p_title, v_song_old.title),
        description    = COALESCE(p_description, v_song_old.description),
        Release_date   = COALESCE(p_release_date, v_song_old.release_date),
        duration       = COALESCE(p_duration, v_song_old.duration),
        image_filepath = COALESCE(p_image_filepath, v_song_old.image_filepath)
    WHERE id = p_song_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;

-- Function 7.7
CREATE OR REPLACE FUNCTION get_song_history(p_song_id int) return SYS_REFCURSOR
    IS
    history Sys_Refcursor;
BEGIN
    OPEN history FOR
        SELECT *
        FROM SONG_HISTORY
        WHERE SONG_HISTORY.SONG_ID = p_song_id
        ORDER BY SONG_HISTORY.MODIFIED_AT;

    return history;
END;

-- Function 7.8
CREATE OR REPLACE FUNCTION get_normalized_song_title(p_song_id int) RETURN VARCHAR
    IS
    v_song_title Song.title%type;
    v_result     VARCHAR(2000);
    CURSOR c_interprets IS
        SELECT interpret.name
        FROM interpret_song is_
                 JOIN interpret ON interpret.id = is_.interpret_id
        WHERE is_.song_id = p_song_id;
BEGIN
    v_result := '';

    SELECT title INTO v_song_title FROM song WHERE song.id = p_song_id;

    FOR record IN c_interprets
        LOOP
            v_result := v_result || record.NAME || ' & ';
        END LOOP;

    v_result := RTRIM(v_result, ' & ');

    if v_result IS NOT NULL then
        v_result := v_result || ' - ';
    end if;

    v_result := v_result || v_song_title;

    return v_result;
END;


-- Function 7.9
CREATE OR REPLACE PROCEDURE delete_song(p_song_id SONG.id%type)
    IS
    v_container_id CONTAINER.id%type;
BEGIN
    SELECT song.CONTAINER_ID into v_container_id FROM SONG WHERE SONG.ID = p_song_id;

    DELETE FROM PLAYLIST_ITEM where PLAYLIST_ITEM.SONG_ID = p_song_id;
    DELETE FROM SONG_HISTORY where SONG_HISTORY.SONG_ID = p_song_id;
    DELETE FROM CONTAINER_GENRE where CONTAINER_GENRE.CONTAINER_ID = v_container_id;
    DELETE FROM RATING where RATING.CONTAINER_ID = v_container_id;
    DELETE FROM "COMMENT" where "COMMENT".CONTAINER_ID = v_container_id;
    DELETE FROM SONG where SONG.ID = p_song_id;
    DELETE FROM CONTAINER where CONTAINER.ID = v_container_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;