DROP TABLE interpret_history;
DROP TABLE song_history;
DROP TABLE playlist_item;
DROP TABLE playlist;
DROP TABLE "COMMENT";
DROP TABLE rating;
DROP TABLE "USER";
DROP TABLE container_genre;
DROP TABLE genre;
DROP TABLE interpret_song;
DROP TABLE interpret;
DROP TABLE song;
DROP TABLE container;


create table container
(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);


create table song
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title          varchar(150)                        not null,
    description    varchar(2000),
    duration       DOUBLE PRECISION,
    release_date   DATE,
    image_filepath varchar(260),
    created        TIMESTAMP default CURRENT_TIMESTAMP not null,
    container_id   int                                 not null
        constraint SONG_CONTAINER_ID_FK
            references container (id)
);

create table interpret
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name           varchar(100)                        not null,
    description    varchar(2000),
    image_filepath varchar(260),
    created        TIMESTAMP default CURRENT_TIMESTAMP not null,
    container_id   int                                 not null
        references container (id)
);

create table interpret_song
(
    interpret_id int not null
        references interpret (id),

    song_id      int not null
        references song (id)
);


create table genre
(
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(100) not null
);

create table container_genre
(
    container_id int not null
        references container (id),

    genre_id     int not null
        references genre (id)
);

create table "USER"
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username       varchar(20)                         not null,
    email          varchar(50)                         not null,
    created        TIMESTAMP default CURRENT_TIMESTAMP not null,
    password_hash  varchar(16)                         not null,
    is_blocked     CHAR(1)                             not null,
    is_deleted     CHAR(1)                             not null,
    role           char,
    image_filepath varchar(260)
);

create table rating
(
    value        int not null,
    user_id      int not null
        references "USER" (id),
    container_id int not null
        references container (id)
);

create table "COMMENT"
(
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    text         VARCHAR(2000)                       not null,
    created      TIMESTAMP default CURRENT_TIMESTAMP not null,
    user_id      int                                 not null
        references "USER" (id),
    container_id int                                 not null
        references container (id)
);

create table playlist
(
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title          VARCHAR(150)                        not null,
    is_private     CHAR(1)                             not null,
    image_filepath varchar(260),
    description    varchar(2000),
    created        TIMESTAMP default CURRENT_TIMESTAMP not null,
    user_id        int                                 not null
        references "USER" (id),
    container_id   int                                 not null
        references container (id)
);

create table playlist_item
(
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    position    int not null,
    song_id     int not null
        references song (id),
    playlist_id int not null
        references playlist (id)
);


create table song_history
(
    modified_at TIMESTAMP default CURRENT_TIMESTAMP,
    song_id     int
        references song (id),

    new_title          varchar(150),
    new_description    varchar(2000),
    new_duration       DOUBLE PRECISION,
    new_release_date   DATE,
    new_image_filepath varchar(260),


    user_id            int not null
        references "USER" (id),

    primary key (modified_at, song_id)
);

create table interpret_history
(
    modified_at  TIMESTAMP default CURRENT_TIMESTAMP,
    interpret_id int
        references interpret (id),

    new_name           varchar(100),
    new_description    varchar(2000),
    new_image_filepath varchar(260),


    user_id            int not null
        references "USER" (id),

    primary key (modified_at, interpret_id)
);

INSERT INTO "USER" (username, email, created, password_hash, is_blocked, is_deleted, role, image_filepath)
VALUES ('User1', 'user1@email.com', DEFAULT, '512354', '0', '0', null, null);

INSERT INTO "USER" (username, email, created, password_hash, is_blocked, is_deleted, role, image_filepath)
VALUES ('User2', 'user2@email.com', DEFAULT, '512354', '0', '0', null, null);

-- Song
DECLARE
    v_container_id      int;
    v_song_id           int;
    v_song_title        Song.title%type;
    v_song_release_date Song.release_date%type;
    v_song_duration     Song.duration%type;
    v_user_id           int;
    v_rating_value      int;

BEGIN
    FOR i in 1 .. 10
        LOOP
            v_song_title := 'Song' || i;
            v_song_release_date := TO_DATE('2023-04-1', 'yyyy-mm-dd') + i;
            v_song_duration := dbms_random.value(1, 5);
            v_user_id := trunc(dbms_random.value(1, 3));


            INSERT INTO container VALUES (DEFAULT) RETURNING id INTO v_container_id;


            INSERT INTO song (title, description, release_date, duration, container_id, image_filepath)
            VALUES (v_song_title, null, v_song_release_date, v_song_duration, v_container_id, null)
            RETURNING id INTO v_song_id;

            INSERT INTO song_history (song_id, new_title, new_description, new_duration, new_release_date,
                                      new_image_filepath, user_id)
            VALUES (v_song_id, v_song_title, null, v_song_duration, v_song_release_date, null, v_user_id);

            FOR j in 0 .. trunc(dbms_random.value(5, 15))
                LOOP
                    v_user_id := trunc(dbms_random.value(1, 3));
                    v_rating_value := trunc(dbms_random.value(1, 6));
                    INSERT INTO rating (value, user_id, container_id)
                    VALUES (v_rating_value, v_user_id, v_container_id);

                    INSERT INTO "COMMENT" (text, created, user_id, container_id)
                    VALUES ('Comment' || j, DEFAULT, v_user_id, v_container_id);
                end loop;
        end loop;
end;

-- Interpret
DECLARE
    v_container_id   int;
    v_interpret_id   int;
    v_interpret_name Song.title%type;
    v_user_id        int;
    v_rating_value   int;

BEGIN
    FOR i in 1 .. 4
        LOOP
            v_interpret_name := 'Interpret' || i;
            v_user_id := trunc(dbms_random.value(1, 3));


            INSERT INTO container VALUES (DEFAULT) RETURNING id INTO v_container_id;


            INSERT INTO interpret (name, description, image_filepath, container_id)
            VALUES (v_interpret_name, null, null, v_container_id)
            RETURNING id INTO v_interpret_id;

            INSERT INTO interpret_history (interpret_id, new_name, new_description, new_image_filepath, user_id)
            VALUES (v_interpret_id, v_interpret_name, null, null, v_user_id);

            FOR j in 0 .. trunc(dbms_random.value(5, 15))
                LOOP
                    v_user_id := trunc(dbms_random.value(1, 3));
                    v_rating_value := dbms_random.value(1, 6);
                    INSERT INTO rating (value, user_id, container_id)
                    VALUES (v_rating_value, v_user_id, v_container_id);

                    INSERT INTO "COMMENT" (text, created, user_id, container_id)
                    VALUES ('Comment' || j, DEFAULT, v_user_id, v_container_id);
                end loop;
        end loop;
end;


-- Interpret song
DECLARE
    v_interpret_id int;
    v_song_id      int;
    v_index        int;
    v_count        int;
BEGIN
    v_index := 0;


    while v_index < 20
        loop
            v_song_id := trunc(dbms_random.value(1, 11));
            v_interpret_id := trunc(dbms_random.value(1, 5));

            SELECT COUNT(*)
            into v_count
            from interpret_song
            where interpret_id = v_interpret_id
              and song_id = v_song_id;

            if v_count = 0 then
                INSERT INTO interpret_song (interpret_id, song_id) VALUES (v_interpret_id, v_song_id);
                v_index := v_index + 1;
            end if;

        end loop;
end;

-- Genre
DECLARE
    v_container_id   int;
    v_interpret_id   int;
    v_interpret_name Song.title%type;
    v_user_id        int;
    v_rating_value   int;

BEGIN
    FOR i in 1 .. 3
        LOOP
            v_interpret_name := 'Interpret' || i;
            v_user_id := trunc(dbms_random.value(1, 3));


            INSERT INTO genre (NAME) VALUES ('Genre' || i);
        end loop;
end;


-- container(song) genre
DECLARE
    v_container_id int;
    v_genre_id     int;
    v_index        int;
    v_count        int;
BEGIN
    v_index := 0;


    while v_index < 15
        loop
            v_container_id := trunc(dbms_random.value(1, 10 + 4 + 1));
            v_genre_id := trunc(dbms_random.value(1, 3 + 1));

            SELECT COUNT(*)
            into v_count
            from CONTAINER_GENRE
            where container_id = v_container_id
              and genre_id = v_genre_id;

            if v_count = 0 then
                INSERT INTO CONTAINER_GENRE (container_id, genre_id) VALUES (v_container_id, v_genre_id);
                v_index := v_index + 1;
            end if;

        end loop;
end;
