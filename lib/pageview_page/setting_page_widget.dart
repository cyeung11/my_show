import 'package:flutter/material.dart';
import 'package:my_show/drive/auth_manager.dart';
import 'package:my_show/drive/show_back_up_helper.dart';
import 'package:my_show/page/info_page.dart';
import 'package:my_show/show_storage_helper.dart';

class SettingPageWidget extends StatefulWidget {

  final ShowStorageHelper _pref;

  final authMan = AuthManager();

  SettingPageWidget(this._pref, {Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();

}

class _SettingPageState extends State<SettingPageWidget>{

  String loginName;
  bool switchValue;

  @override
  void initState() {
    super.initState();
    loginName = widget._pref.getString(PREF_DRIVE_USER_NAME);
    switchValue = loginName?.isNotEmpty == true;
  }

  @override
  Widget build(BuildContext context) {

    var loginColumn = <Widget>[Text('Google Account',
      style: TextStyle(color: Colors.white, fontSize: 18),
    )];
    if (loginName?.isNotEmpty == true) {
      loginColumn.add(Text(loginName, style: TextStyle(color: Colors.grey, fontSize: 12),));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            InkWell(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Text('Privacy',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward, color: Colors.white)
                    ],
                  ),
                ),
              ),
              onTap: (){
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext _) {
                          return InfoPage();
                        }
                    )
                );
              },
            ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Row(
                  children: <Widget>[
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                        children: loginColumn,
                      ),
                    Spacer(),
                    Switch(
                      value: switchValue,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.blueGrey,
                      inactiveTrackColor: Colors.white24,
                      inactiveThumbColor: Colors.grey,
                      onChanged: (on){
                        setState(() {
                          switchValue = !switchValue;
                        });
                        if (on) {
                          widget.authMan.getAccount().then((acc){
                            setState(() {
                              if (acc?.email?.isNotEmpty == true) {
                                loginName = acc.email;
                                widget._pref.setValue(PREF_DRIVE_USER_NAME, acc.email);
                                switchValue = true;
                              } else {
                                widget._pref.setValue(PREF_DRIVE_USER_NAME, null);
                                switchValue = false;
                              }
                            });
                          });
                        } else {
                          setState(() {
                            widget.authMan.signOut();
                            widget._pref.setValue(PREF_DRIVE_USER_NAME, null);
                            loginName = null;
                            switchValue = false;
                          });
                        }
                      },
                    )
                  ],
                ),
              ),

            InkWell(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Text('Backup Now',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward, color: Colors.white)
                    ],
                  ),
                ),
              ),
              onTap: (){
                widget.authMan.getAccount().then((acc){
                  ShowBackupHelper(acc, widget._pref).backup();
                });
              },
            ),

            InkWell(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Text('Restore',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward, color: Colors.white)
                    ],
                  ),
                ),
              ),
              onTap: (){
                widget.authMan.getAccount().then((acc){
                  ShowBackupHelper(acc, widget._pref).restore();
                });
              },
            ),
//            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: Text('MyShow by C H Yeung\n\nThis APP uses the TMDb API but is not endorsed or certified by TMDb.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}