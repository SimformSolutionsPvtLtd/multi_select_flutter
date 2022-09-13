import 'package:flutter/material.dart';

import '../util/multi_select_actions.dart';
import '../util/multi_select_item.dart';
import '../util/multi_select_list_type.dart';

/// A bottom sheet widget containing either a classic checkbox style list, or a chip style list.
class CustomMultiSelectBottomSheet<T> extends StatefulWidget
    with MultiSelectActions<T> {
  /// List of items to select from.
  final List<MultiSelectItem<T>> items;

  /// The list of selected values before interaction.
  final List<T> initialValue;

  /// The text at the top of the BottomSheet.
  final Widget? title;

  /// Fires when the an item is selected / unselected.
  final void Function(List<T>)? onSelectionChanged;

  /// Fires when confirm is tapped.
  final void Function(List<T>, [String?])? onConfirm;

  /// Toggles search functionality.
  final bool searchable;

  /// Text on the confirm button.
  final Text? confirmText;

  /// Text on the cancel button.
  final Text? cancelText;

  /// An enum that determines which type of list to render.
  final MultiSelectListType? listType;

  /// Sets the color of the checkbox or chip when it's selected.
  final Color? selectedColor;

  /// Set the initial height of the BottomSheet.
  final double? initialChildSize;

  /// Set the minimum height threshold of the BottomSheet before it closes.
  final double? minChildSize;

  /// Set the maximum height of the BottomSheet.
  final double? maxChildSize;

  /// Set the placeholder text of the search field.
  final String? searchHint;

  /// A function that sets the color of selected items based on their value.
  /// It will either set the chip color, or the checkbox color depending on the list type.
  final Color? Function(T)? colorator;

  /// Color of the chip body or checkbox border while not selected.
  final Color? unselectedColor;

  /// Icon button that shows the search field.
  final Icon? searchIcon;

  /// Icon button that hides the search field
  final Icon? closeSearchIcon;

  /// Style the text on the chips or list tiles.
  final TextStyle? itemsTextStyle;

  /// Style the text on the selected chips or list tiles.
  final TextStyle? selectedItemsTextStyle;

  /// Style the search text.
  final TextStyle? searchTextStyle;

  /// Style the search hint.
  final TextStyle? searchHintStyle;

  /// Moves the selected items to the top of the list.
  final bool separateSelectedItems;

  /// Set the color of the check in the checkbox
  final Color? checkColor;

  final Widget? emptyListPlaceHolder;

  final void Function(List<T>)? clearAll;

  final bool? enableClearAll;

  ///This function is used to compare selected items with Items list and return
  /// List of Multi select items to create chips
  /// e.g
  /// checkCondition: (selectedItems, itemsList) {
  ///                         if (itemsList.isEmpty) {
  ///                          return [];
  ///                         }
  ///                         return selectedItems
  ///                            .map((e) => itemsList.firstWhere(
  ///                                 (element) => e.id == element.value.id))
  ///                            .toList();
  ///
  final List<MultiSelectItem<T>>? Function(List<T>, List<MultiSelectItem<T>>)?
      checkCondition;

  final bool multiSelect;

  final Widget? contentHeader;

  final ValueNotifier<int>? itemLength;

  CustomMultiSelectBottomSheet(
      {required this.items,
      required this.initialValue,
      this.title,
      this.onSelectionChanged,
      this.onConfirm,
      this.listType,
      this.cancelText,
      this.confirmText,
      this.searchable = false,
      this.selectedColor,
      this.initialChildSize,
      this.minChildSize,
      this.maxChildSize,
      this.colorator,
      this.unselectedColor,
      this.searchIcon,
      this.closeSearchIcon,
      this.itemsTextStyle,
      this.searchTextStyle,
      this.searchHint,
      this.searchHintStyle,
      this.selectedItemsTextStyle,
      this.separateSelectedItems = false,
      this.checkColor,
      this.emptyListPlaceHolder,
      this.clearAll,
      this.enableClearAll = false,
      this.checkCondition,
      this.multiSelect = true,
      this.contentHeader,
      this.itemLength})
      : assert(!(enableClearAll == true && clearAll == null),
            'clearAll cannot be null while enableClearAll is true');

  @override
  _CustomMultiSelectBottomSheetState<T> createState() =>
      _CustomMultiSelectBottomSheetState<T>(items);
}

class _CustomMultiSelectBottomSheetState<T>
    extends State<CustomMultiSelectBottomSheet<T>> {
  List<T> _selectedValues = [];
  bool _showSearch = false;
  List<MultiSelectItem<T>> _items;

  TextEditingController searchController = TextEditingController();

  _CustomMultiSelectBottomSheetState(this._items);

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.initialValue);

    for (int i = 0; i < _items.length; i++) {
      if (_selectedValues.contains(_items[i].value)) {
        _items[i].selected = true;
      }
    }

    if (widget.separateSelectedItems) {
      _items = widget.separateSelected(_items);
    }
  }

  /// Returns a CheckboxListTile
  Widget _buildListItem(MultiSelectItem<T> item) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: widget.unselectedColor ?? Colors.black54,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (widget.multiSelect) {
              _selectedValues = widget.onItemCheckedChange(
                  _selectedValues, item.value, !item.selected);
            } else {
              _selectedValues = widget.onSingleItemChecked(
                  _selectedValues, item.value, !item.selected);
              widget.items.forEach((element) {
                if (element.label != item.label) {
                  element.selected = false;
                }
              });
            }
            if (item.selected) {
              item.selected = false;
            } else {
              item.selected = true;
            }
            if (widget.separateSelectedItems) {
              _items = widget.separateSelected(_items);
            }
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: widget.itemsTextStyle,
              ),
              Visibility(
                visible: item.selected,
                child: Icon(Icons.check, color: widget.selectedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a ChoiceChip
  Widget _buildChipItem(MultiSelectItem<T> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        backgroundColor: widget.unselectedColor,
        selectedColor:
            widget.colorator != null && widget.colorator!(item.value) != null
                ? widget.colorator!(item.value)
                : widget.selectedColor != null
                    ? widget.selectedColor
                    : Theme.of(context).primaryColor.withOpacity(0.35),
        label: Text(
          item.label,
          style: _selectedValues.contains(item.value)
              ? TextStyle(
                  color: widget.selectedItemsTextStyle?.color ??
                      widget.colorator?.call(item.value) ??
                      widget.selectedColor?.withOpacity(1) ??
                      Theme.of(context).primaryColor,
                  fontSize: widget.selectedItemsTextStyle != null
                      ? widget.selectedItemsTextStyle!.fontSize
                      : null,
                )
              : widget.itemsTextStyle,
        ),
        selected: item.selected,
        onSelected: (checked) {
          if (checked) {
            item.selected = true;
          } else {
            item.selected = false;
          }
          setState(() {
            if (widget.multiSelect) {
              _selectedValues = widget.onItemCheckedChange(
                  _selectedValues, item.value, checked);
            } else {
              _selectedValues = widget.onSingleItemChecked(
                  _selectedValues, item.value, checked);
            }
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DraggableScrollableSheet(
        initialChildSize: widget.initialChildSize ?? 0.3,
        minChildSize: widget.minChildSize ?? 0.3,
        maxChildSize: widget.maxChildSize ?? 0.95,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          final expanded = () => Expanded(
            child: widget.listType == null ||
                widget.listType == MultiSelectListType.LIST
                ? (_items.length == 0)
                ? (widget.emptyListPlaceHolder == null)
                ? Center(child: Text("No data found"))
                : widget.emptyListPlaceHolder!
                : ListView.builder(
              controller: scrollController,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildListItem(_items[index]);
              },
            )
                : SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Wrap(
                  children: _items.map(_buildChipItem).toList(),
                ),
              ),
            ),
          );
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xFFD2D2D2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: widget.title ??
                        Text('Search', textAlign: TextAlign.center),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 0),
                        child: TextFormField(
                          controller: searchController,
                          autofocus: false,
                          style: widget.searchTextStyle,
                          decoration: InputDecoration(
                            hintStyle: widget.searchHintStyle,
                            hintText: widget.searchHint ?? "Search",
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: widget.selectedColor ??
                                      Theme.of(context).primaryColor),
                            ),
                            prefixIcon: _showSearch ? null : Icon(Icons.search),
                            suffixIcon: _showSearch
                                ? IconButton(
                                    onPressed: () {
                                      setState(
                                        () {
                                          searchController.text = '';
                                          _showSearch = !_showSearch;
                                          if (!_showSearch) {
                                            if (widget.separateSelectedItems) {
                                              _items = widget.separateSelected(
                                                  widget.items);
                                            } else {
                                              _items = widget.items;
                                            }
                                          }
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.close),
                                  )
                                : null,
                          ),
                          onChanged: (val) {
                            List<MultiSelectItem<T>> filteredList = [];
                            filteredList =
                                widget.updateSearchQuery(val, widget.items);
                            setState(() {
                              val.isNotEmpty
                                  ? _showSearch = true
                                  : _showSearch = false;
                              if (widget.separateSelectedItems) {
                                _items = widget.separateSelected(filteredList);
                              } else {
                                _items = filteredList;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              widget.contentHeader ?? Container(),
              const SizedBox(height: 5),
              if(widget.itemLength != null) ValueListenableBuilder(
                valueListenable: widget.itemLength!,
                builder: (_, value, __) {
                  return expanded();
                },
              ) else expanded(),
              Container(
                padding: EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SafeArea(
                        child: Container(
                          height: 45,
                          margin: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onConfirmTap(
                                  context, _selectedValues, widget.onConfirm, searchController.text);
                            },
                            child: widget.confirmText ??
                                Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
