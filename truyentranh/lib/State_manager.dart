import 'package:flutter_riverpod/all.dart';

import 'Chapters.dart';
import 'comic.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected=StateProvider((ref)=> Chapters());
final isSearch=StateProvider((ref)=>false);