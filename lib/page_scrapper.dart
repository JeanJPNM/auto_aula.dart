import 'dart:async';
import 'dart:io';

import 'package:auto_aula/dates/holidays.dart';
import 'package:auto_aula/types/class_subject.dart';
import 'package:auto_aula/types/lab_class.dart';
import 'package:auto_aula/types/online_class.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:puppeteer/puppeteer.dart';

import 'providers/data_provider.dart';

@sealed
abstract class Urls {
  static const home = 'https://objetivo.br';
  static const onlineClasses = 'https://objetivo.br/portal-aluno/aulas-ao-vivo';
  static const studentMenu = 'https://objetivo.br/portal-aluno/central';
}

class PageScrapper {
  PageScrapper({
    required this.onlineClasses,
    required this.dataState,
    required this.page,
  });
  Page page;
  final List<OnlineClass> onlineClasses;
  final DataState dataState;

  String? get pathToChrome {
    String env(String variable) =>
        Platform.environment[variable] ?? r'c:\program files (x86)';
    final paths = [
      join(env('ProgramFiles(x86)'), r'Google\Chrome\Application\chrome.exe'),
      join(env('ProgramFiles'), r'Google\Chrome\Application\chrome.exe'),
      join(env('LocalAppData'), r'Google\Chrome\Application\chrome.exe'),
    ];
    String? result;
    for (final path in paths) {
      final file = File(path);
      if (file.existsSync()) result = file.path;
    }
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

  Future<void> _login(String user, String password) async {
    final loginButton = await page.$('#login') as ElementHandle?;
    if (loginButton == null) return;
    await page.type('#matricula', user);
    await page.type('#senha', password);
    await page.clickAndWaitForNavigation('#login', wait: Until.networkIdle);
    final alertDiv = await page.$('div.alert-danger') as ElementHandle?;
    final alertSpan = await page.$('span#msgErro') as ElementHandle?;
    if (alertDiv != null || alertSpan != null) {
      throw Exception('Login inválido');
    }
  }

  Future<void> _enterClass(OnlineClass onlineClass, UserData state) async {
    final now = DateTime.now();
    if (now.isAfter(onlineClass.end)) return;
    await Future.delayed(onlineClass.start.difference(now));
    String currentLink = '';
    while (true) {
      await page.reload();
      final links = await page.$$('a.link-aula');
      int index = 0;
      if (links.length > 1) {
        if (currentLab == LabClass.bio) {
          index = 1;
        }
      } else if (links.isEmpty) {
        await Future.delayed(const Duration(seconds: 5));
        await page.reload();
        continue;
      }
      final linkElement = links[index];
      final link =
          await (await linkElement.property('href')).jsonValue as String;
      if (link != currentLink) {
        currentLink = link;
        await Future.wait([
          linkElement.click(),
          page.waitForNavigation(),
        ]);
        await page.waitForSelector('div[role=button]');
        await page.click('div[role=button]');
        await Future.delayed(const Duration(seconds: 20));
        await page.goto(Urls.home);
        break;
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Stream<int> watchClasses() async* {
    final state = dataState as UserData;
    await page.goto(Urls.home);
    await _login(state.user!, state.password!);
    await page.goto(Urls.onlineClasses);
    for (var i = 0; i < onlineClasses.length; i++) {
      final onlineClass = onlineClasses[i];
      if (await page.$('#login') != null) {
        await page.goto(Urls.home);
        await _login(state.user!, state.password!);
        await page.goto(Urls.onlineClasses);
      }
      await _enterClass(onlineClass, state);
      yield i;
    }
  }

  Future<void> startExam(PTClassSubject subject, int bimester) async {
    final state = dataState as UserData;
    await page.goto(Urls.home);
    await _login(state.user!, state.password!);
    await page.clickAndWaitForNavigation('a#202');
    await page.clickAndWaitForNavigation('div.contentBox div a');
    final subjects = [
      PTClassSubject.pgb,
      PTClassSubject.pga,
      PTClassSubject.filosofia,
      PTClassSubject.sociologia,
      PTClassSubject.biologia,
      PTClassSubject.edFis,
      PTClassSubject.fisica,
      PTClassSubject.geografia,
      PTClassSubject.historia,
      PTClassSubject.informatica,
      PTClassSubject.ingles,
      PTClassSubject.portugues,
      PTClassSubject.matematica,
      PTClassSubject.quimica,
    ];
    final index = subjects.indexOf(subject);
    assert(index != -1, 'The subject must be a valid exam subject');
    await page
        .clickAndWaitForNavigation('ul.courseListing li:nth-child($index) a');
    await page.clickAndWaitForNavigation(
      'ul#content_listContainer li:nth-child(${bimester + 1}) a',
    );
    // todo: discover the selector for the link to the test
  }

  //
  Future<void> reset({
    required Page newPage,
  }) async {
    page = newPage;
  }
}
