import 'package:http/http.dart' as http;
import 'dart:convert';

// please import ninja pakage
// dart pub add ninja
import 'package:ninja/asymmetric/rsa/rsa.dart';


// you shoud get the private key when you sign up for Walmart Affiliates API (you should obviously secure your private key)
final String walmartPrivateKey = "S/K7mi2blSHcFiWcVTrgj1wse7L56kTbM2fpj6SoQldEoSius8Dou3jOD84ejodIF/30Jd....";

// you shoud get the consumer ID when you sign up for Walmart Affiliates API
final String walmartConsumerId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";

final String priviateKeyVersion = "1";


 Map<String, String> generateSignature() {
    try {
      int currentDateInMillSec = new DateTime.now().millisecondsSinceEpoch;
      String intTimeStamp = currentDateInMillSec.toString();
      final Map map = {
        "WM_CONSUMER.ID": walmartConsumerId,
        "WM_CONSUMER.INTIMESTAMP": intTimeStamp,
        "WM_SEC.KEY_VERSION": priviateKeyVersion,
      };

      final sortedHashString =
          '${map["WM_CONSUMER.ID"]}\n${map["WM_CONSUMER.INTIMESTAMP"]}\n${map["WM_SEC.KEY_VERSION"]}\n';

      final rsaPrivateKey = RSAPrivateKey.fromPEM(walmartPrivateKey);
      final signatureEnc = rsaPrivateKey.signSsaPkcs1v15ToBase64(sortedHashString);
      return {
        "WM_SEC.AUTH_SIGNATURE": signatureEnc,
        "WM_CONSUMER.INTIMESTAMP": intTimeStamp,
        "WM_CONSUMER.ID": walmartConsumerId,
        "WM_SEC.KEY_VERSION": priviateKeyVersion,
      };
    } catch (e) {
      // print(e);
      // throw e;
      // do whatever you want if an error occured !!
    }
  }

  final walmartHeaderSigned = generateSignature();


  // to use the header and make an http request

  String publisherId = "1234567" // use your publisher Id if you have one
  String query = "Coffee maker" // whatever you want to search for

 // test against Search API 
 Uri _url = Uri.parse(
      'https://developer.api.walmart.com/api-proxy/service/affil/product/v2/search?publisherId=$publisherId' +
          '&query=$query' +
          '&sort=relevance&' +
          'numItems=25' +
          '&responseGroup=base',
    );

        http.Response response = await http.get(_url, headers: walmartHeaderSigned);
        final extractedData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        print(extractedData);





