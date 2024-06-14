package min0139;


import lombok.*;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;

@Getter
@Setter
@AllArgsConstructor
public class Song
{
    private Integer id;
    private String title;
    private Double duration;
    private String description;
    private java.sql.Date release_date;
    private java.sql.Timestamp created;
    private String imageFilepath;

    public Song(Integer id, String title)
    {
        this.id = id;
        this.title = title;
    }
}
