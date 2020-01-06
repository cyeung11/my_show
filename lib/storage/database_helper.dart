import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static Database db;

  static const TABLE_TV = 'tv';
  static const TABLE_MOVIE = 'movie';

  static Future<void> initDb() async{
    if (db == null) {
      db = await openDatabase(
        join(await getDatabasesPath(), 'my_show.db'),
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS $TABLE_TV($tvTableColumn)');
          return db.execute('CREATE TABLE IF NOT EXISTS $TABLE_MOVIE($movieTableColumn)',
          );
        },
        version: 1,
      );
    }
  }

  static const tvTableColumn =  'id INTEGER PRIMARY KEY,'
      'backdrop_path TEXT,'
      'homepage TEXT,'
      'name TEXT,'
      'original_name TEXT,'
      'overview TEXT,'
      'popularity REAL,'
      'poster_path TEXT,'
      'status TEXT,'
      'vote_average REAL,'
      'vote_count INTEGER,'
      'genres TEXT,'
      'production_companies TEXT,'
      'first_air_date TEXT,'
      'in_production REAL DEFAULT false,'
      'last_air_date TEXT,'
      'number_of_episodes INTEGER,'
      'number_of_seasons INTEGER,'
      'original_language TEXT,'
      'type TEXT,'
      'created_by TEXT,'
      'episode_run_time TEXT,'
      'languages TEXT,'
      'last_episode_to_air TEXT,'
      'networks TEXT,'
      'next_episode_to_air TEXT,'
      'origin_country TEXT,'
      'seasons TEXT,'
      'progress TEXT,'
      'savedTime INTEGER';

  static const movieTableColumn =  'id INTEGER PRIMARY KEY,'
      'backdrop_path TEXT,'
      'genres TEXT,'
      'homepage TEXT,'
      'name TEXT,'
      'original_name TEXT,'
      'overview TEXT,'
      'popularity REAL,'
      'poster_path TEXT,'
      'status TEXT,'
      'vote_average REAL,'
      'vote_count INTEGER,'
      'budget INTEGER,'
      'production_companies TEXT,'
      'production_countries TEXT,'
      'original_language TEXT,'
      'release_date TEXT,'
      'spoken_languages TEXT,'
      'runtime INTEGER,'
      'revenue INTEGER,'
      'imdb_id TEXT,'
      'tagline TEXT,'
      'adult REAL DEFAULT false,'
      'video REAL DEFAULT false,'
      'savedTime INTEGER';
}