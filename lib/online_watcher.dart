import 'dart:async';
import 'dart:io';

import 'package:auto_aula/dates/holidays.dart';
import 'package:auto_aula/types/lab_class.dart';
import 'package:auto_aula/types/online_class.dart';
import 'package:path/path.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:puppeteer/puppeteer.dart';
import 'providers/data_provider.dart';

const _classUrl = 'https://objetivo.br/portal-aluno/aulas-ao-vivo';

class OnlineWatcher {
  OnlineWatcher({
    required this.onlineClasses,
    required this.dataState,
  }) : _completers = onlineClasses.map((e) => Completer()).toList();
  Browser? browser;
  Page? page;
  final List<OnlineClass> onlineClasses;
  final DataState dataState;
  final List<Completer> _completers;

  String? get pathToChrome {
    String env(String variable) =>
        Platform.environment[variable] ?? r'c:\program files (x86)';
    final paths = [
      join(env("ProgramFiles(x86)"), r"Google\Chrome\Application\chrome.exe"),
      join(env("ProgramFiles"), r"Google\Chrome\Application\chrome.exe"),
      join(env("LocalAppData"), r"Google\Chrome\Application\chrome.exe"),
    ];
    String? result;
    for (final path in paths) {
      final file = File(path);
      print(file);
      if (file.existsSync()) result = file.path;
    }
    print(result);
    return result;
  }

  LabClass get currentLab {
    final start = DateTime(2021, 2, 2);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = (today.difference(start).inDays / 7).floor();
    final pastHolidays = holidays.where(
        (date) => date.isBefore(now) && date.weekday == DateTime.tuesday);
    final weeks = days - pastHolidays.length;
    if (weeks % 2 == 0) {
      return LabClass.info;
    }
    return LabClass.bio;
  }

  List<Future> get onlineClassesComplete =>
      _completers.map((e) => e.future).toList();
  Future<void> init() async {
    browser = await puppeteer.launch(
      defaultViewport: null,
      headless: false,
      executablePath: pathToChrome,
      userDataDir:
          join(Platform.environment['appdata']!, "auto_aula/browser_data"),
    );
    page = await browser!.newPage();
    page!.defaultTimeout = const Duration(minutes: 2);
  }

  Future<void> _login(String user, String password) async {
    final loginButton = await page!.$('#login') as ElementHandle?;
    if (loginButton == null) return;
    await page!.type('#matricula', user);
    await page!.type('#senha', password);
    await page!.clickAndWaitForNavigation('#login', wait: Until.networkIdle);
  }

  Future<void> _enterClass(OnlineClass onlineClass, UserData state) async {
    final now = DateTime.now();
    if (now.isAfter(onlineClass.end)) return;
    await Future.delayed(onlineClass.start.difference(now));
    String currentLink = "";
    while (true) {
      await page?.reload();
      final links = await page!.$$('a.link-aula');
      int index = 0;
      if (links.length > 1) {
        if (currentLab == LabClass.bio) {
          index = 1;
        }
      } else if (links.length == 0) {
        await Future.delayed(const Duration(seconds: 5));
        await page!.reload();
        continue;
      }
      final linkElement = links[index];
      String link = await (await linkElement.property('href')).jsonValue;
      if (link != currentLink) {
        currentLink = link;
        await Future.wait([
          linkElement.click(),
          page!.waitForNavigation(),
        ]);
        await page!.waitForSelector('div[role=button]');
        await page!.click('div[role=button]');
        await Future.delayed(const Duration(seconds: 20));
        await page!.goto(_classUrl);
        break;
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Stream<int> start() async* {
    if (browser == null || page == null) await reset();
    final state = dataState as UserData;
    await page!.goto('http://objetivo.br');
    await _login(state.user!, state.password!);
    await page!.goto(_classUrl);
    for (var i = 0; i < onlineClasses.length; i++) {
      final onlineClass = onlineClasses[i];
      if (await page!.$('#login') != null) {
        _login(state.user!, state.password!);
        await page!.goto(_classUrl);
      }
      await _enterClass(onlineClass, state);
      yield i;
    }
  }

  Future<void> reset() async {
    await browser?.close();
    browser = await puppeteer.launch(defaultViewport: null, headless: false);
    page = await browser!.newPage();
  }

  Future<void> dispose() async {
    await browser?.close();
    browser = null;
    page = null;
  }
}
