import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:ecommerce/components/my_button.dart';
import 'package:ecommerce/components/my_drawer.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // remove item from cart method
  void removeItemFromCart(BuildContext context, Product product) {
    // show a dialog box to ask user to confirm to remove cart
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text("Remove this item from your cart?"),
        actions: [
          // cancel button
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // yes button
          MaterialButton(
            onPressed: () {
              // pop dialog box
              Navigator.pop(context);

              // remove from cart
              context.read<Shop>().removeFromCart(product);
              setState(() {});  // Refresh the total price
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  String environment = "PRODUCTION";
  String appId = "null";
  String merchantId = "M22M72SHPPH6V";
  bool enableLogging = true;

  String packageName = "";
  String saltkey = "0b90fa50-16e2-4c80-93a5-253cb8a68042";
  String saltIndex = "1";
  String callbackurl = "https://webhook.site/callback-url";

  String body = "";
  String apiEndPoint = "/pg/v1/pay";

  Object? _result;
  String _paymentStatus = "";

  String string_signature = "";
  @override
  void initState() {
    phonepePaymentInit();
    super.initState();
  }

  void _onPayNowClicked() {
    startPGTransaction();
    setState(() {
      _paymentStatus = "";
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // get access to the cart
    final cart = context.watch<Shop>().cart;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cart Page'),
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // cart list
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Your cart is empty..."))
                : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                // Get individual item in cart
                final item = cart[index];

                // Return as a cart tile UI
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "http://ecommerce.raviva.in/productimage/${item.image!}",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.productName!),
                  subtitle: Text(item.price!),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => removeItemFromCart(context, item),
                  ),
                );
              },
            ),
          ),

          // total price
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: ₹${getTotalPrice(cart)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // pay button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyButton(
              text: "PAY NOW",
              onTap: _onPayNowClicked,
              child: const Text("PAY NOW"),
            ),
          ),
        ],
      ),
    );
  }

  void phonepePaymentInit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
      setState(() {
        _result = 'PhonePe SDK Initialized - $val';
      })
    })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void handleError(error) {
    setState(() {
      _result = {"error": error};
    });
  }

  void startPGTransaction() async {
    final String transactionId =
    DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, Object> requestData = getRequestData(transactionId);

    String body = getBase64Body(requestData);
    String checksum = getCheckSum(requestData);

    PhonePePaymentSdk.startTransaction(body, callbackurl, checksum, packageName)
        .then((response) async {
      String message = "";
      if (response != null) {
        String status = response['status'].toString();
        String error = response['error'].toString();
        if (status == 'SUCCESS') {
          message = "Flow Completed - Status: Success!";
          await checkPaymentStatus(transactionId);
        } else {
          message = "Flow Completed - Status: $status and Error: $error";
        }
      } else {
        message = "Flow Incomplete";
      }

      setState(() {
        _result = message;
      });
    }).catchError((error) {
      handleError(error);
      // return <dynamic>{};
    });
  }

  Map<String, Object> getRequestData(String transactionId) {
    final cart = context.read<Shop>().cart;
    var amount = getTotalPrice(cart) * 100;

    print("amount = $amount");
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": transactionId,
      "merchantUserId": "MUID123",
      "amount": amount,
      "callbackUrl": callbackurl,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };

    return requestData;
  }

  String getBase64Body(Map<String, Object> requestData) {
    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    return base64Body;
  }

  String getCheckSum(Map<String, Object> requestData) {
    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    String checksum =
        '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltkey)).toString()}###$saltIndex';

    return checksum;
  }

  checkPaymentStatus(String transactionId) async {
    try {
      String url =
          "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$transactionId";

      String xVerifyString = "/pg/v1/status/$merchantId/$transactionId$saltkey";
      var bytes = utf8.encode(xVerifyString);
      var digest = sha256.convert(bytes).toString();

      String xVerify = '$digest###$saltIndex';

      Map<String, String> requestHeader = {
        "Content-Type": "application/json",
        "X-VERIFY": xVerify,
        "X-CLIENT-ID": merchantId
      };

      await http.get(Uri.parse(url), headers: requestHeader).then((value) {
        Map<String, dynamic> response = jsonDecode(value.body);

        try {
          if (response["success"] &&
              response["code"] == "PAYMENT_SUCCESS" &&
              response["data"]["paymentState"] == "COMPLETED") {
            _paymentStatus =
            "${response["message"]} \n TransactionId: $transactionId";
          } else {
            _paymentStatus =
            "${response["message"]} \n TransactionId: $transactionId";
          }
        } catch (e) {
          _paymentStatus = "Error : ${e.toString()}";
        }
      });
    } catch (e) {
      _paymentStatus = "Error : Something went wrong}";
    }
  }

  // Calculate total price of items in the cart
  int getTotalPrice(List<Product> cart) {
    int totalPrice = 0;
    for (var item in cart) {
      totalPrice += int.parse(item.price!);
    }
    return totalPrice;
  }
}
