import 'dart:async';
import 'dart:io';

String baseURl =
    'https://raw.githubusercontent.com/bsutton/dcli/master/test/src/functions/fetch_downloads';

void main() async {
  final completer = Completer<void>();
  var saveToPath = '/tmp/sample.acc';

  var fetchUrl = '$baseURl/sample.aac';

  var saveTo = File(saveToPath);

  if (saveTo.existsSync()) {
    saveTo.deleteSync();
  }

  final client = HttpClient();
  await client.getUrl(Uri.parse(fetchUrl)).then((request) {
    return request.close();
  }).then((response) async {
    var lengthReceived = 0;

    final contentLength = response.contentLength;
    print('exepeted: $contentLength');

    late StreamSubscription<List<int>> subscription;
    subscription = response.listen(
      (newBytes) async {
        lengthReceived += newBytes.length;
        print('recieved $lengthReceived');
      },
      onDone: () async {
        client.close();

        assert(contentLength == lengthReceived);

        completer.complete();
      },
      onError: (Object e, StackTrace st) async {
        await subscription.cancel();
        completer.completeError(e, st);
      },
      cancelOnError: true,
    );
  });

  await completer.future;
  print('finished');
}
