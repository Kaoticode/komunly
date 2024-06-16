import 'package:flutter/material.dart';
import 'package:komunly/data/betsData.dart';
import 'package:komunly/theme/colors.dart';

class BetsWidget extends StatefulWidget {
  const BetsWidget({super.key});

  @override
  State<BetsWidget> createState() => _BetsWidgetState();
}

class _BetsWidgetState extends State<BetsWidget> {
  int selectedValue = 0;
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
     height: MediaQuery.of(context).size.height - 80,
      child: ListView.builder(
        itemCount: BetsData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white),
                  color: grey),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    BetsData[index]["caption"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: white,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona una opción:',
                        style: TextStyle(color: white),
                      ),
                      buildRadioButton(
                          1, BetsData[index]["opcion1"], BetsData[index]["cuota1"]),
                      buildRadioButton(
                          2, BetsData[index]["opcion2"], BetsData[index]["cuota2"]),
                      buildRadioButton(
                          3, BetsData[index]["opcion3"], BetsData[index]["cuota3"]),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: white, fontSize: 16),
                    decoration: InputDecoration(
                      helperMaxLines: 1,
                      labelText: 'Ingrese la cantidad',
                      labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.6), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                      hintText: 'Ej. 100',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 16),
                      prefixIcon:
                          const Icon(Icons.attach_money, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (BetsData[index]["apuestaRealizada"] == true)
                    const Text(
                      "Ya has participado en esta apuesta. Solo se puede participar una vez por apuesta.",
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => print({
                        'selectedValue': selectedValue,
                        'amount': amountController.text,
                      }),
                      style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(const Size(120, 40)),
                      ),
                      child:
                          const Text('Apostar', style: TextStyle(color: black)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRadioButton(int value, String label, String cuota) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedValue = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: selectedValue == value ? Colors.blue : Colors.grey[800],
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              '$label ($cuota)',
              style: TextStyle(
                color: selectedValue == value ? white : white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
