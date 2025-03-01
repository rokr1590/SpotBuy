import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotbuy/screens/message/components/chat_screen.dart';

import '../../../size_config.dart';
import '../../../models/categories_model.dart';
import '../../../provider/vehicle_provider.dart';

class MainVehicleList extends StatelessWidget {
  const MainVehicleList({
    Key? key,
    required this.selectedCategory,
  }) : super(key: key);

  final CategoriesModel selectedCategory;
  void fetchData(List data, BuildContext context) {
    Provider.of<VehicleProvider>(context).fetchAllVehicleData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicle_database')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var data = snapshot.data!.docs as List;
            // print(data[0]['image']);\
            // data.forEach((element) {});
            fetchData(data, context);

            final vehicleList = Provider.of<VehicleProvider>(context)
                .getVehicleById(selectedCategory.id);
            return GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: vehicleList.length,
              itemBuilder: (context, index) => Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(getProportionateScreenWidth(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: vehicleList[index].image.length,
                          itemBuilder: (context, inde) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(
                              vehicleList[index].image[inde],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        vehicleList[index].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getProportionateScreenWidth(30),
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(5),
                      ),
                      Text(
                        vehicleList[index].yearModel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getProportionateScreenWidth(15),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            backgroundColor: const Color(0xFFF5AAAA),
                            label: Text(
                              vehicleList[index].ownerNo + ' owner',
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(15),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: getProportionateScreenWidth(5),
                          ),
                          Chip(
                            backgroundColor: const Color(0xFFBAF4AA),
                            label: Text(
                              vehicleList[index].kmDriven + ' KM',
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(15),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: getProportionateScreenWidth(5),
                          ),
                          Chip(
                            backgroundColor: const Color(0xFFAAD2F5),
                            label: Text(
                              vehicleList[index].fuelType,
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getProportionateScreenWidth(20),
                        ),
                      ),
                      Text(
                        vehicleList[index].descriptionText,
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: getProportionateScreenWidth(15),
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenWidth(10),
                      ),
                      Text(
                        '${vehicleList[index].sellAmount} \u{20B9}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getProportionateScreenWidth(30),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: getProportionateScreenHeight(50),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      toId: vehicleList[index].itemBy,
                                      name: vehicleList[index].itemByName,
                                    )));
                          },
                          icon: const Icon(Icons.message),
                          label: Text(
                            'Start chatting'.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getProportionateScreenWidth(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2),
            );
          }),
    );
  }
}
