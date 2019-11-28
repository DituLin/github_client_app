
import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_client_app/common/Git.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/i10n/localization_intl.dart';
import 'package:github_client_app/models/repo.dart';
import 'package:github_client_app/states/ProfileChangeNotifier.dart';
import 'package:github_client_app/widgets/repo_item.dart';
import 'package:provider/provider.dart';

class HomeRoute extends StatefulWidget{
  @override
  _HomeRouteState createState() => _HomeRouteState();

}

class _HomeRouteState extends State<HomeRoute>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GmLocalizations.of(context).home),
      ),
      body: _buildBody(),
      drawer: MyDrawer(),
    );
  }

  Widget _buildBody() {
    UserModel userModel = Provider.of<UserModel>(context);
    if(!userModel.isLogin) {
      return Center(
        child: RaisedButton(
          child: Text(GmLocalizations.of(context).login),
          onPressed: () => Navigator.of(context).pushNamed("login"),
        ),
      );
    }else{
      //已登录，则显示项目列表
      return InfiniteListView<Repo>(
        onRetrieveData: (int page,List<Repo> itmes,bool refresh) async{
          var data = await Git(context).getRepo(
            queryParameters: {
              'page':page,
              'page_size':20,
            },
            refresh: refresh
          );
          itmes.addAll(data);
          // 如果接口返回的数量等于'page_size'，则认为还有数据，反之则认为最后一页
          return data.length == 20;
        },
        itemBuilder: (List list, int index, BuildContext ctx){
          // 项目信息列表项
          return RepoItem(list[index]);
        },
      );
    }
  }

}




class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                Expanded(
                  child: _buildMenus(),
                )
              ],
            )),
    );
  }

  //构建抽屉菜单头部
  Widget _buildHeader() {
    return Consumer<UserModel>(
      builder: (BuildContext context,UserModel userModel,Widget widget){
        return GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(top: 40,bottom: 20),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipOval(
                    child: userModel.isLogin ? gmAvatar(userModel.user.avatar_url,width: 80)
                        : Image.asset("imgs/avatar-default.png",width: 80,),
                  ),
                ),
                Text(
                  userModel.isLogin ? userModel.user.login:GmLocalizations.of(context).login,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
          onTap: (){
            if(!userModel.isLogin) Navigator.of(context).pushNamed("login");
          },
        );
      },
    );
  }

  // 构建菜单项
  Widget _buildMenus() {
      return Consumer<UserModel>(
        builder: (BuildContext context,UserModel userModel,Widget widget){
          var gm = GmLocalizations.of(context);
          return ListView(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(gm.theme),
                  onTap: ()=> Navigator.pushNamed(context, "themes"),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(gm.language),
                  onTap: ()=> Navigator.pushNamed(context, "language"),
                ),
                if(userModel.isLogin)ListTile(

                  leading: const Icon(Icons.power_settings_new),
                  title: Text(gm.logout),
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (ctx){
                          return AlertDialog(
                            content: Text(gm.logoutTip),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(gm.cancel),
                                onPressed: () => Navigator.pop(context),
                              ),
                              FlatButton(
                                  child: Text(gm.yes),
                                  onPressed: () {
                                    //该赋值语句会触发MaterialApp rebuild
                                    userModel.user = null;
                                    Navigator.pop(context);
                                  }
                              )
                            ],
                          );
                        }
                    );
                  },
                )
              ],
          );
        }
      );
  }

}