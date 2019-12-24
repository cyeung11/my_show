import 'package:flutter/material.dart';
import 'package:my_show/page/info_page.dart';

class SettingPageWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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