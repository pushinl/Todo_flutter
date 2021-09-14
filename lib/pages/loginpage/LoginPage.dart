import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:todo_flutter/bean/user_bean_entity.dart';
import 'package:todo_flutter/pages/Color.dart';

import '../../main.dart';
import '../Constants.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

const APP_KEY = "banana";
const APP_SECRET = "37b590063d593716405a2c5a382b1130b28bf8a7";
const DOMAIN = "weipeiyang.twt.edu.cn";

class _LoginRouteState extends State<LoginRoute> {

  TextEditingController _unameController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  bool pwdShow = false; //密码是否显示明文
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _nameAutoFocus = true;

  @override
  void initState() {
    if (_unameController.text != null) {
      _nameAutoFocus = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var gm = GmLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
        elevation: 0,
        leading: IconButton(
          iconSize: 36,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            'assets/back.png',
            width: 25,
            height: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Image.asset('assets/twt_assets/twt.png'),
              Text(
                '使用天外天账号登录',
                style: TextStyle(
                    fontSize: 22
                ),
              ),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                  autofocus: _nameAutoFocus,
                  controller: _unameController,
                  decoration: InputDecoration(
                    labelText: 'TWT账号',
                    hintText: '使用TWT账号登录',
                    prefixIcon: Icon(
                      Icons.person,
                      color: ColorUtils.color_blue_main,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorUtils.color_grey_666),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  // 校验用户名（不能为空）
                  validator: (v) {
                    return v
                        .trim()
                        .isNotEmpty ? null : '账号不能为空';
                  }),
              TextFormField(
                controller: _pwdController,
                autofocus: !_nameAutoFocus,
                decoration: InputDecoration(
                  labelText: 'TWT密码',
                  hintText: '使用TWT密码登录',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: ColorUtils.color_blue_main,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      pwdShow ? Icons.visibility_off : Icons.visibility,
                      color: ColorUtils.color_blue_main,
                    ),
                    onPressed: () {
                      setState(() {
                        pwdShow = !pwdShow;
                      });
                    },
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorUtils.color_grey_666),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                obscureText: !pwdShow,
                //校验密码（不能为空）
                validator: (v) {
                  return v
                      .trim()
                      .isNotEmpty ? null : '密码不能为空';
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55.0),
                  child: ElevatedButton(
                    onPressed: _onLogin,
                    child: Text('登录'),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(ColorUtils.color_blue_main),
                      foregroundColor:
                      MaterialStateProperty.all(ColorUtils.color_white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLogin() async {
    // 提交前，先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      UserBeanResult user;
      UserBeanEntity result1;
      String ticket = base64Encode(utf8.encode(APP_KEY + '.' + APP_SECRET));
      print(ticket);
      Map<String, String> headers = {"DOMAIN": DOMAIN, "ticket": ticket};
      var result = await Dio().post("http://42.193.115.210:8080/api/login",
          options: Options(headers: headers),
          queryParameters: {
            "account": _unameController.text,
            "password": _pwdController.text
          });
      print(result);
      result1 = UserBeanEntity().fromJson(result.data);
      if (result1.code == 0) {
        user = result1.result;
        Global.isLogin = true;
        Global.user = user;
        // print(Global.user.idNumber);YmFuYW5hLjM3YjU5MDA2M2Q1OTM3MTY0MDVhMmM1YTM4MmIxMTMwYjI4YmY4YTc=
        Navigator.of(context).pop(Constants.REFRESH);
      } else {
        Toast.show('发生了一些错误~', context);
      }
    }
  }
}
