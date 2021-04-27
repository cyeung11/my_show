import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_show/drive/auth_manager.dart';
import 'package:my_show/drive/show_back_up_helper.dart';
import 'package:my_show/page/info_page.dart';
import 'package:my_show/storage/pref_helper.dart';

class SettingPageWidget extends StatefulWidget {

  final ValueChanged<GoogleSignInAccount> _onRestoreNeed;

  final AuthManager _authMan;

  SettingPageWidget(this._onRestoreNeed, this._authMan, {Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();

}

class _SettingPageState extends State<SettingPageWidget>{

  String loginName;
  bool switchValue;

  @override
  void initState() {
    super.initState();
    loginName = PrefHelper.instance.getString(PREF_DRIVE_USER_NAME);
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text('INFO',
                  style: TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 2,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            InkWell(
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text('BACKUP',
                  style: TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 2,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 24),
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
                        widget._authMan.getAccount().then((acc){
                          setState(() {
                            if (acc?.email?.isNotEmpty == true) {
                              loginName = acc.email;
                              PrefHelper.instance.setString(PREF_DRIVE_USER_NAME, acc.email);
                              switchValue = true;

                              Fluttertoast.showToast(
                                  msg: 'Searching for backup…',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                              );

                              widget._onRestoreNeed(acc);

                            } else {
                              PrefHelper.instance.setString(PREF_DRIVE_USER_NAME, null);
                              switchValue = false;
                            }
                          });
                        });
                      } else {
                        setState(() {
                          widget._authMan.signOut();
                          PrefHelper.instance.setString(PREF_DRIVE_USER_NAME, null);
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
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child:  Text('Backup now',
                      style: TextStyle(color: switchValue ? Colors.white : Colors.grey, fontSize: 18),
                    ),
                  ),
                ),
              ),
              onTap: switchValue ? (){
                widget._authMan.getAccount().then((acc){
                  ShowBackupHelper.backup(acc);
                });
              } : null,
            ),
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