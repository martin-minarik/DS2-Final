package min0139;


import oracle.jdbc.OracleTypes;

import java.sql.*;
import java.util.ArrayList;

public class SongDAO
{
    public static String SQL_CALL_CREATE_SONG = "{? = call CREATE_SONG (?, ?, ?, ?, ?, ?)}";
    public static String SQL_CALL_UPDATE_SONG = "{call UPDATE_SONG (?, ?, ?, ?, ?, ?, ?)}";
    public static String SQL_CALL_DELETE_SONG = "{call DELETE_SONG (?)}";
    public static String SQL_SELECT = "SELECT * FROM song";
    public static String SQL_SELECT_ID = "SELECT * FROM song WHERE song.id=?";
    public static String SQL_CALL_GET_BY_INTERPRET_ID = "{call GET_SONGS_BY_INTERPRET_ID (?, ?)}";
    public static String SQL_CALL_GET_BY_GENRE_ID = "{call GET_SONGS_BY_GENRE_ID (?, ?)}";
    public static String SQL_CALL_SEARCH_SONG = "{? = call SEARCH_SONGS (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
    public static String SQL_CALL_GET_NORMALIZED_TITLE = "{? = call GET_NORMALIZED_SONG_TITLE (?)}";
    public static String SQL_CALL_GET_SONG_HISTORY = "{? = call GET_SONG_HISTORY (?)}";


    static public Integer insert(Song song, int user_id, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();

        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_CREATE_SONG))
        {
            statement.registerOutParameter(1, OracleTypes.INTEGER);
            statement.setObject(2, user_id);
            statement.setObject(3, song.getTitle());
            statement.setObject(4, song.getDuration());
            statement.setObject(5, song.getRelease_date());
            statement.setObject(6, song.getDescription());
            statement.setObject(7, song.getImageFilepath());
            statement.execute();

            return  (Integer) statement.getObject(1);

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }

    static public void update(Song song, int user_id, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();

        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_UPDATE_SONG))
        {
            statement.setInt(1, user_id);
            statement.setInt(2, song.getId());
            statement.setString(3, song.getTitle());
            statement.setObject(4, song.getDuration());
            statement.setObject(5, song.getRelease_date());
            statement.setObject(6, song.getDescription());
            statement.setObject(7, song.getImageFilepath());
            statement.execute();

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }

    static public void delete(int songId, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();

        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_DELETE_SONG))
        {
            statement.setInt(1, songId);
            statement.execute();

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }

    static public Song find(int songId, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();


        try (PreparedStatement statement = db.createPreparedStatement(SQL_SELECT_ID))
        {
            statement.setInt(1, songId);
            try (ResultSet resultSet = db.select(statement))
            {
                return songFromResultSet(resultSet);

            }

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }


    static public ArrayList<Song> getAll(Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();


        try (PreparedStatement statement = db.createPreparedStatement(SQL_SELECT))
        {
            try (ResultSet resultSet = db.select(statement))
            {
                return songsFromResultSet(resultSet);
            }


        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }

    }


    static public ArrayList<Song> getAllByInterpretId(int interpretId, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();

        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_GET_BY_INTERPRET_ID))
        {
            statement.setInt(1, interpretId);
            statement.registerOutParameter(2, OracleTypes.CURSOR);
            statement.execute();

            try (ResultSet resultSet = (ResultSet) statement.getObject(2))
            {
                return songsFromResultSet(resultSet);
            }

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }

    }

    static public ArrayList<Song> getAllByGenreId(int genreId, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();


        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_GET_BY_GENRE_ID))
        {
            statement.setInt(1, genreId);
            statement.registerOutParameter(2, OracleTypes.CURSOR);
            statement.execute();

            try (ResultSet resultSet = (ResultSet) statement.getObject(2))
            {
                return songsFromResultSet(resultSet);
            }

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }


    static public ArrayList<Song> searchSongs(SongSearchParams params,
                                              Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();

        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_SEARCH_SONG))
        {

            statement.registerOutParameter(1, OracleTypes.CURSOR);


            statement.setObject(2, params.keyword);
            statement.setObject(3, params.min_rating);
            statement.setObject(4, params.max_rating);
            statement.setObject(5, params.min_number_of_comments);
            statement.setObject(6, params.interpret);
            statement.setObject(7, params.genre);
            statement.setObject(8, params.min_duration);
            statement.setObject(9, params.max_duration);
            statement.setObject(10, params.created_before);
            statement.setObject(11, params.created_after);
            statement.setObject(12, params.released_before);
            statement.setObject(13, params.released_after);
            statement.setObject(14, params.order_by);

            statement.execute();

            try (ResultSet resultSet = (ResultSet) statement.getObject(1))
            {
                return songsFromResultSet(resultSet);
            }

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }


    static public String getNormalizedTitle(int songId, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();


        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_GET_NORMALIZED_TITLE))
        {
            statement.registerOutParameter(1, OracleTypes.VARCHAR);
            statement.setInt(2, songId);
            statement.execute();

            return statement.getString(1);

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }

    static public ArrayList<SongHistory> getSongHistory(Song song, Database db_as_param)
    {
        Database db = db_as_param;
        if (db == null)
            db = new Database();

        if (!db.isConnected())
            db.connect();


        try (CallableStatement statement = db.createCallableStatement(SQL_CALL_GET_SONG_HISTORY))
        {
            statement.registerOutParameter(1, OracleTypes.CURSOR);
            statement.setInt(2, song.getId());

            try
            {
                statement.execute();
            } catch (SQLException e)
            {
                throw new RuntimeException(e);
            }

            try (ResultSet resultSet = (ResultSet) statement.getObject(1))
            {
                return songHistoryFromResultSet(resultSet);
            }

        } catch (SQLException e)
        {
            throw new RuntimeException(e);
        } finally
        {
            if (db_as_param == null)
                db.close();
        }
    }

    static private Song songFromResultSet(ResultSet resultSet) throws SQLException
    {
        if (resultSet.next())
            return new Song(
                    resultSet.getInt("id"),
                    resultSet.getString("title"),
                    resultSet.getDouble("duration"),
                    resultSet.getString("description"),
                    resultSet.getDate("release_date"),
                    resultSet.getTimestamp("created"),
                    resultSet.getString("image_filepath"));

        return null;
    }

    static private ArrayList<Song> songsFromResultSet(ResultSet resultSet) throws SQLException
    {
        ArrayList<Song> songs = new ArrayList<>();
        Song song = songFromResultSet(resultSet);
        while (song != null)
        {
            songs.add(song);
            song = songFromResultSet(resultSet);
        }

        return songs;
    }

    static private ArrayList<SongHistory> songHistoryFromResultSet(ResultSet resultSet) throws SQLException
    {
        ArrayList<SongHistory> songHistories = new ArrayList<>();
        while (resultSet.next())
        {
            songHistories.add(new SongHistory(
                    resultSet.getInt("song_id"),
                    resultSet.getInt("user_id"),
                    resultSet.getTimestamp("modified_at"),
                    resultSet.getString("new_title"),
                    resultSet.getDouble("new_duration"),
                    resultSet.getString("new_description"),
                    resultSet.getDate("new_release_date"),
                    resultSet.getString("new_image_filepath"))
            );
        }

        return songHistories;
    }
}
