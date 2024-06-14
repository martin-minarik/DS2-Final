package min0139;

import lombok.*;

import java.sql.Date;
import java.sql.Timestamp;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
public class SongSearchParams
{
    String keyword;
    Integer min_rating;
    Integer max_rating;
    Integer min_number_of_comments;
    String interpret;
    String genre;
    Float min_duration;
    Float max_duration;
    Timestamp created_before;
    Timestamp created_after;
    Date released_before;
    Date released_after;
    String order_by;
}
