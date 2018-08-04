import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';

const TEMPLATE_PATH    = 'https://github.com/petehouston/dart-library-template/archive/master.zip';
const TEMPLATE_FILE    = 'template.zip';
const DEFAULT_LIB_NAME = 'dart-library-template-master';

void printUsage() {
  final usage = """
    -------------------
    | create-dart-lib |
    -------------------
    An utility to generate a Dart library template.

    Usage:
        \$ create-dart-lib LIBRARY_NAME

    Example:
        \$ create-dart-lib my-hello-lib

  """;
  print(usage);
}

Future _downloadPackage() async {
  
  final httpClient = new HttpClient();
  return httpClient.getUrl(Uri.parse(TEMPLATE_PATH))
    .then((HttpClientRequest request) {
      return request.close();
    })
    .then((HttpClientResponse response) async {
      await response.pipe(new File(TEMPLATE_FILE).openWrite());      
    });
    
}

Future _generateLibrary() async {
  final List<int> bytes = new File(TEMPLATE_FILE).readAsBytesSync();

  Archive archive = new ZipDecoder().decodeBytes(bytes);
  
  for (ArchiveFile file in archive) {    
    final String filename = file.name;    
    if (file.isFile) {
      dynamic data = file.content;
      new File('./' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data as List<int>);
    } else {
      new Directory('./' + filename)
          ..create(recursive: true);      
    }      
  }
}

Future _clean(String name) async {  
  try {
    Directory packageDir = new Directory(DEFAULT_LIB_NAME);
    packageDir.renameSync(name);  
    packageDir.deleteSync(recursive: true);    
  } on Exception catch (e) {
    //
  }
}


main(List<String> args) async {
  
  if(args.length < 1) {
    printUsage();
    return;
  }

  print('Please wait...');
  await _downloadPackage();
    
  await _generateLibrary()
    .then((dynamic d) =>_clean(args[0]));


  return;
}