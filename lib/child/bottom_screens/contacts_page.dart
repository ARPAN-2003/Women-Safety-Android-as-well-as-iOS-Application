import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';
import 'package:women_safety_app/utils/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    askPermissions();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContacts(){
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = element.displayName ?? "";
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch == true) {
          return true;
        }
        if (searchTermFlatten.isEmpty) {
          return false;
        }
        var phone = element.phones!.firstWhere((p) {
          String phoneFlattered = flattenPhoneNumber(p.value!);
          return phoneFlattered.contains(searchTermFlatten);
        });
        return phone.value != null;
      });
    }

    setState(() {
      contactsFiltered = _contacts;
    });
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if(permissionStatus == PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
    else {
      handleInvalidPermissions(permissionStatus);
    }
  }

  handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialogueBox(context, "Access to the contacts denied by the user");
    }
    else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      dialogueBox(context, "May contact does exist on this device");
    }
  }

  Future<PermissionStatus> getContactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    }
    else {
      return permission;
    }
  }

  getAllContacts() async {
    List<Contact> _contacts = await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemExit = (contactsFiltered.length > 0 || contacts.length > 0);
    return Scaffold(
      appBar: AppBar(title: Text('Contacts'), backgroundColor: primaryColor),
      body: contacts.length == 0 ? Center(child: CircularProgressIndicator())
      : SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search Contact",
                  prefixIcon: Icon(Icons.search_rounded)
                ),
              ),
            ),
            listItemExit == true
            ? Expanded(
              child: ListView.builder(
                  itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                  Contact contact = isSearching == true ? contactsFiltered[index] : contacts[index];

                  String displayName = contact.displayName!;
                  String phoneNumber = contact.phones != null && contact.phones!.length > 0 ? contact.phones!.first.value! ?? "No Number" : "No Number";

                  return ListTile(
                      title: Text(contact.displayName ?? ""),
                      subtitle: Text(phoneNumber),    // Text(contact.phones!.elementAt(0).value!),
                      leading: contact.avatar != null && contact.avatar!.length > 0
                        ? CircleAvatar(backgroundColor: primaryColor, backgroundImage: MemoryImage(contact.avatar!))
                        : CircleAvatar(backgroundColor: primaryColor, child: Text(displayName.length > 0 ? contact.initials() : "NN")),
                      onTap: () {
                        if (contact.phones!.length > 0) {
                          final String phoneNum = contact.phones!.elementAt(0).value!;
                          final String name = contact.displayName!;
                          _addContact(TContact(phoneNum, name));
                        }
                        else {
                          Fluttertoast.showToast(msg: "OOPS! Phone Number of this contact does not exist");
                        }
                    },
                  );
                  }),
            )
            : Container(
              child: Text("Searching"),
            ),
          ],
        ),
      )
    );
  }
  void _addContact(TContact newContact) async {
    int result = await _databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact added successfully");
    }
    else {
      Fluttertoast.showToast(msg: "Failed to add contacts");
    }
    Navigator.of(context).pop(true);
  }
}
