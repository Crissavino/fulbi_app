class Currency {

  Currency({
    this.id,
    this.code,
    this.selected,
  });

  int? id;
  String? code;
  bool? selected;

  List<Currency> get currencies {
    return [
      Currency(id: 1, code: '€', selected: false),
      Currency(id: 2, code: '£', selected: false),
      Currency(id: 3, code: '\$', selected: false)
    ];
  }

}