// import 'package:flutter/material.dart';

// class SelectCategorysWidget extends StatefulWidget {
//   const SelectCategorysWidget({ Key? key }) : super(key: key);

//   @override
//   _SelectCategorysWidgetState createState() => _SelectCategorysWidgetState();
// }

// class _SelectCategorysWidgetState extends State<SelectCategorysWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
      
//     );
//   }

//       Widget _selectCategory({
//       required BuildContext context,
//       required List category,
//       required Color? categoryDropdownColor,
//       required String defaultSelectText,
//       required String subcategoryHintTextDropdown,
//       required String subsubcategoryHintTextDropdown,
//       required String cindOfCategory,
//       required String? selectedCategoryId,
//       required String? selectedSubcategoryId,
//       required String? selectedSubsubcategoryId,
//       required String? suggestedSubcategoryId,
//       required Color? subcategoryDropdownColor,
//       required Color? subsubcategoryDropdownColor,
//       required bool subcategoryIsActive,
//       required bool? validateSubcategory,
//       required String? iosCategoryName,
//       required String? iosSubcategoryName,
//       required String? iosSubsubcategoryName,
//       required BorderSide? iosCategoryBorder,
//       required Color iosCategoryColor,
//       required Color iosSubategoryColor,
//       required Color iosSubsubategoryColor,
//       required Color? iosButtonColor,
//       int? categoryIndex,
//       int? subcategoryIndex,
//       int? subsubcategoryIndex,
//     }) {
//       if (Platform.isAndroid) {
//         return DropdownButton<dynamic>(
//           items: category.map((dynamic dropDownStringItem) {
//             return DropdownMenuItem<dynamic>(
//               child: Text(dropDownStringItem["name"].toString(),
//                   overflow: TextOverflow.ellipsis),
//               value: dropDownStringItem["id"].toString(),
//             );
//           }).toList(),
//           hint: Text(
//             defaultSelectText,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(color: categoryDropdownColor),
//           ),
//           onChanged: (dynamic newValueSelected) {
//             if (cindOfCategory == "Category") {
//               setState(() {
//                 selectedSubcategoryId = null;
//                 selectedSubsubcategoryId = null;
//                 suggestedSubcategoryId = null;
//                 selectedCategoryId = null;
//                 subcategoryHintTextDropdown = "Select Subcategory";
//                 subsubcategoryHintTextDropdown = "Select SubSubcategory";
//                 subcategoryDropdownColor = null;
//                 selectedCategoryId = newValueSelected;
//                 subcategorys = Provider.of<Subcategorys>(context, listen: false)
//                     .findByCategoryId(newValueSelected);
//                 subcategoryIsActive = true;
//                 validateSubcategory = false;
//               });
//             }
//             if (cindOfCategory == "Subcategory") {
//               setState(() {
//                 suggestedSubcategoryId = null;
//                 validateSubcategory = false;
//                 selectedSubsubcategoryId = null;
//                 subsubcategoryHintTextDropdown = "Select Subsubrubric";
//                 suggestedSubcategoryId = newValueSelected["id"];
//                 validateSubcategory =
//                     newValueSelected["must_pick_subsubcategory"];
//               });

//               if (validateSubcategory == true) {
//                 subsubcategorys =
//                     Provider.of<Subsubcategorys>(context, listen: false)
//                         .findBySubcategoryId(newValueSelected["id"]);
//               }
//             }
//           },
//           value: cindOfCategory == "Category"
//               ? selectedCategoryId
//               : cindOfCategory == "Subcategory"
//                   ? selectedSubcategoryId
//                   : selectedSubsubcategoryId,
//         );
//       } else {
//         return SizedBox(
//           width: MediaQuery.of(context).size.width * 0.7,
//           height: MediaQuery.of(context).size.height * 0.05,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               side: iosCategoryBorder,
//               primary: iosButtonColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(23.0),
//               ),
//             ),
//             child: Text(
//               cindOfCategory == 'Category'
//                   ? iosCategoryName!
//                   : cindOfCategory == 'Subcategory'
//                       ? iosSubcategoryName!
//                       : iosSubsubcategoryName!,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: cindOfCategory == 'Category'
//                     ? iosCategoryColor
//                     : cindOfCategory == 'Subcategory'
//                         ? iosSubategoryColor
//                         : iosSubsubategoryColor,
//                 fontSize: 15,
//               ),
//             ),
//             onPressed: () async {
//               if (cindOfCategory == "Category") {
//                 rubricIndex = null;
//                 subrubricIndex = null;
//                 setState(() {
//                   iosCategoryBorder = null;
//                   iosCategoryColor = Colors.white;
//                 });
//               }
//               if (cindOfCategory == "Subcategory") {
//                 subrubricIndex = null;
//                 setState(() {
//                   _subcategoryBorder = null;
//                   _subcategoryColor = Colors.white;
//                 });
//               }
//               if (cindOfCategory == "Subsubcategory") {
//                 rubricIndex = null;
//                 subrubricIndex = null;
//                 setState(() {
//                   iosCategoryBorder = null;
//                   iosCategoryColor = Colors.white;
//                 });
//               }
//               await showCupertinoModalPopup(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.39,
//                     child: Column(
//                       children: [
//                         Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Container(
//                             height: MediaQuery.of(context).size.height * 0.045,
//                             color: CupertinoColors.white,
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                   right:
//                                       MediaQuery.of(context).size.width * 0.03),
//                               child: Align(
//                                 alignment: Alignment.centerRight,
//                                 child: TextButton(
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                     if (cindOfCategory == "Category") {
//                                       setState(() {
//                                         selectedCategoryId = null;
//                                         print("hier isssa");
//                                         selectedSubcategoryId = null;
//                                         selectedSubsubcategoryId = null;
//                                         selectedCategoryId =
//                                             category[categoryIndex!].id;
//                                         iosCategoryName =
//                                             category[categoryIndex!].name;
//                                         iosSubcategoryName =
//                                             "Select Subcategory";
//                                         iosSubsubcategoryName =
//                                             "Select Subsubcategory";

//                                         subcategoryIsActive = true;
//                                         validateSubcategory = false;
//                                       });
//                                     }
//                                     if (cindOfCategory == "Subcategory") {
//                                       if (subrubricIndex == null) {
//                                         setState(() {
//                                           selectedSubcategoryId = null;
//                                           selectedSubsubcategoryId = null;
//                                           validateSubcategory = false;
//                                           selectedSubcategoryId =
//                                               category[subcategoryIndex!]["id"];
//                                           validateSubcategory =
//                                               category[subcategoryIndex!]
//                                                   ["must_pick_subsubcategory"];
//                                           iosSubcategoryName =
//                                               category[subcategoryIndex!]
//                                                   ["name"];
//                                           iosSubsubcategoryName =
//                                               "Select Subsubcategory";
//                                         });
//                                       }
//                                     }
//                                     if (cindOfCategory == "Subsubcategory") {
//                                       setState(() {
//                                         selectedCategoryId = null;

//                                         selectedSubcategoryId = null;
//                                         selectedSubsubcategoryId = null;
//                                         selectedCategoryId =
//                                             category[categoryIndex!]["id"];
//                                         iosCategoryName =
//                                             category[categoryIndex!]["name"];
//                                         iosSubcategoryName =
//                                             "Select Subcategory";
//                                         iosSubsubcategoryName =
//                                             "Select Subsubcategory";

//                                         subcategoryIsActive = true;
//                                         validateSubcategory = false;
//                                       });
//                                     }
//                                   },
//                                   child: const Text(
//                                     "Done",
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           height: MediaQuery.of(context).size.height * 0.345,
//                           color: Colors.white,
//                           child: CupertinoPicker(
//                             backgroundColor: CupertinoColors.white,
//                             itemExtent:
//                                 MediaQuery.of(context).size.height * 0.05,
//                             children: category.map((item) {
//                               print("itemmm: " + item.toString());
//                               return Center(
//                                 child: Text(
//                                   item.name,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               );
//                             }).toList(),
//                             diameterRatio: 1.0,
//                             onSelectedItemChanged: (value) {
//                               if (cindOfCategory == "Category") {
//                                 setState(() {
//                                   selectedSubsubcategoryId = null;
//                                   validateSubcategory = false;
//                                   selectedSubcategoryId = null;
//                                   selectedCategoryId = null;
//                                   categoryIndex = value;
//                                   selectedCategoryId =
//                                       category[categoryIndex!].id;

//                                   iosCategoryName =
//                                       category[categoryIndex!].name;
//                                   iosSubcategoryName = "Select Subcategory";
//                                   iosSubsubcategoryName =
//                                       "Select Subsubcategory";
//                                   subcategoryIsActive = true;
//                                 });
//                               }

//                               if (cindOfCategory == "Subcategory") {
//                                 setState(() {
//                                   selectedSubcategoryId = null;
//                                   selectedSubsubcategoryId = null;
//                                   validateSubcategory = false;
//                                   iosSubcategoryName = "Select Subsubcategory";
//                                   subcategoryIndex = value;
//                                   selectedSubcategoryId =
//                                       category[subcategoryIndex!]["id"];
//                                   validateSubcategory =
//                                       category[subcategoryIndex!]
//                                           ["must_pick_subsubcategory"];
//                                   iosSubcategoryName =
//                                       category[subcategoryIndex!]["name"];
//                                   notFoundYourSubcategory =
//                                       "Not Found Your Subcategory?";
//                                 });
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       }
//     }
// }