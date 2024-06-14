package min0139;

public class Main {
    public static void main(String[] args) {
        Database db = new Database();

        System.out.println("Waiting for database!");
        db.connect();
        System.out.println("Connected to database!");

        // Demonstrations

        all_songs(db); // Print All song
        System.out.println();

        song_crud(db); // Create, Read, Update, Delete
        System.out.println();

        function_7_2(db);
        System.out.println();

        function_7_3(db);
        System.out.println();

        function_7_4(db);
        System.out.println();

        function_7_7(db);
        System.out.println();

        function_7_8(db);
        System.out.println();

    }

    private static void all_songs(Database db) {
        System.out.println("All Songs:");
        for (Song song : SongDAO.getAll(db)) {
            System.out.println("\t" + song.getId() + "\t" + song.getTitle());
        }
    }


    //function 7.1(create song)
    // function 7.5(song detail - select)
    // function 7.6(song update) is part of crud
    private static void song_crud(Database db) {
        System.out.println("Song crud:");
        int userId = 1;
        Song song = new Song(null, "New song");
        Integer id = SongDAO.insert(song, userId, db);
        Song newSong = SongDAO.find(id, db);
        System.out.println("\tTitle of new song: " + newSong.getTitle());

        newSong.setTitle("Updated new song");
        SongDAO.update(newSong, userId, db);
        System.out.println("\tTitle of new song: " + newSong.getTitle());

        SongDAO.delete(newSong.getId(), db);
    }


    private static void function_7_2(Database db) {
        System.out.println("Function 7.2:");

        SongSearchParams params = SongSearchParams.builder()
                .min_rating(3)
                .order_by("title").build();


        System.out.println("\tSongs with min average rating 3:");
        for (Song song : SongDAO.searchSongs(params, db)) {
            System.out.println("\t\t" + song.getId() + "\t" + song.getTitle());
        }

        params = SongSearchParams.builder()
                .max_duration(4f)
                .order_by("duration").build();

        System.out.println("\tSongs with max duration 3 with order by duration:");
        for (Song song : SongDAO.searchSongs(params, db)) {
            System.out.println("\t\t" + song.getId() + "\t" + song.getTitle() + "\t" + song.getDuration());
        }
    }


    private static void function_7_3(Database db) {
        System.out.println("Function 7.3:");

        System.out.println("\tSongs by genre id 1:");
        for (Song song : SongDAO.getAllByInterpretId(1, db)) {
            System.out.println("\t\t" + song.getId() + "\t" + song.getTitle());
        }
    }

    private static void function_7_4(Database db) {
        System.out.println("Function 7.4:");

        System.out.println("\tSongs by interpret id 2:");
        for (Song song : SongDAO.getAllByGenreId(1, db)) {
            System.out.println("\t\t" + song.getId() + "\t" + song.getTitle());
        }
    }


    private static void function_7_7(Database db) {
        System.out.println("Function 7.7:");

        int userId_1 = 1;
        int userId_2 = 2;
        Song newSong = new Song(null, "New song2");
        int songId = SongDAO.insert(newSong, userId_1, db);

        newSong.setId(songId);
        newSong.setTitle("New song2_edited1");
        SongDAO.update(newSong, userId_1, db);

        newSong.setTitle("New song2_edited2");
        SongDAO.update(newSong, userId_2, db);


        System.out.println("\tSong history of song with id " + songId + ": ");
        for (SongHistory songHistory : SongDAO.getSongHistory(newSong, db)) {
            System.out.println(
                    "\t\tSong Id:" + songHistory.song_id()
                            + "\n\t\t\tModified:" + songHistory.modified().toString()
                            + "\n\t\t\tUser:" + songHistory.user_id()
                            + "\n\t\t\tTitle:" + songHistory.title()

            );
        }

        SongDAO.delete(newSong.getId(), db);
    }

    private static void function_7_8(Database db) {
        System.out.println("Function 7.8:");

        System.out.println("\t" + SongDAO.getNormalizedTitle(1, db));
        System.out.println("\t" + SongDAO.getNormalizedTitle(2, db));
        System.out.println("\t" + SongDAO.getNormalizedTitle(3, db));
    }
}

