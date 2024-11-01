import 'package:sqflite/sqflite.dart';
import 'package:women_safety_app/model/contactsm.dart';

class DatabaseHelper {
  String contactTable = 'contact_table';
  String colId = 'id';
  String colContactName = 'name';
  String colContactNumber = 'number';

  // Private Constructor (used to create an instance of a singleton class)
  // It will be used to create an instance of the DatabaseHelper class
  DatabaseHelper._createInstance();

  // This will be referenced using 'this' keyword... It helps us to access getters and setters of the class
  static DatabaseHelper? _databaseHelper;

  // 'factory' keyword allows the constructor to return some value
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  // Initializing the database...
  static Database? _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String directoryPath = await getDatabasesPath();
    String dbLocation = directoryPath + 'contact.db';

    var contactDatabase = await openDatabase(dbLocation, version: 1, onCreate: _createDbTable);
    return contactDatabase;
  }

  void _createDbTable(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $contactTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colContactName TEXT, $colContactNumber TEXT)');
  }

  // Fetching operation: get contact object from db
  Future<List<Map<String, dynamic>>> getContactMapList() async {
    Database db = await this.database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM $contactTable order by $colId ASC');
    // OR
    // var result = await db.query(contactTable, orderBy: '$colId ASC');
    return result;
  }

  // Inserting a contact object
  Future<int> insertContact(TContact contact) async {
    Database db = await this.database;
    var result = await db.insert(contactTable, contact.toMap());
    // print(await db.query(contactTable));
    return result;
  }

  // Updating a contact object
  Future<int> updateContact(TContact contact) async {
    Database db = await this.database;
    var result = await db.update(contactTable, contact.toMap(), where: '$colId = ?', whereArgs: [contact.id]);
    // print(await db.query(contactTable));
    return result;
  }

  // Deleting a contact object
  Future<int> deleteContact(int id) async {
    Database db = await this.database;
    int result = await db.rawDelete('DELETE FROM $contactTable WHERE $colId = $id');
    // print(await db.query(contactTable));
    return result;
  }

  // Counting the total contact objects
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $contactTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<TContact>> getContactList() async {
    var contactMapList = await getContactMapList();
    int count = contactMapList.length;

    List<TContact> contactList = <TContact>[];

    for(int i=0; i< count; i++){
      contactList.add(TContact.fromMapObject(contactMapList[i]));
    }
    return contactList;
  }
}
