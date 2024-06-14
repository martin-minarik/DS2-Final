package min0139;




public record SongHistory(Integer song_id,
                          Integer user_id,
                          java.sql.Timestamp modified,
                          String title,
                          Double duration,
                          String description,
                          java.sql.Date release_date,
                          String imageFilepath)
{
}
