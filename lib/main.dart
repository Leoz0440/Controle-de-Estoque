import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Garante que a inicialização do Flutter está completa
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase
  await Firebase.initializeApp();
  runApp(const MDFStockApp());
}

class MDFStockApp extends StatelessWidget {
  const MDFStockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Estoque MDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StockPage(),
    );
  }
}

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final String storageKey = "stock_items";

  List<Map<String, String>> stockItems = [];
  List<Map<String, String>> filteredItems = [];

  String tipoFiltro = "Todas";
  String espessuraFiltro = "Todas";
  String marcaFiltro = "Todas";
  String corFiltro = "Todas";

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);

    if (jsonString != null) {
      List<dynamic> jsonData = jsonDecode(jsonString);
      stockItems =
          jsonData.map((item) => Map<String, String>.from(item)).toList();
    } else {
      stockItems = [
        {
          "dimensao": "2750x1830",
          "tipo": "Inteira",
          "espessura": "18mm",
          "marca": "Duratex",
          "cor": "Branco"
        },
        {
          "dimensao": "2750x1830",
          "tipo": "Inteira",
          "espessura": "15mm",
          "marca": "Duratex",
          "cor": "Madeira"
        },
        {
          "dimensao": "2750x1830",
          "tipo": "Cortada",
          "espessura": "18mm",
          "marca": "Eucatex",
          "cor": "Branco"
        },
      ];
    }

    applyFilter();
  }

  Future<void> _saveStockItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stockItems);
    await prefs.setString(storageKey, jsonString);
  }

  void applyFilter() {
    setState(() {
      filteredItems = stockItems.where((item) {
        bool matchTipo = tipoFiltro == "Todas" || item["tipo"] == tipoFiltro;
        bool matchEspessura =
            espessuraFiltro == "Todas" || item["espessura"] == espessuraFiltro;
        bool matchMarca =
            marcaFiltro == "Todas" || item["marca"] == marcaFiltro;
        bool matchCor = corFiltro == "Todas" || item["cor"] == corFiltro;
        return matchTipo && matchEspessura && matchMarca && matchCor;
      }).toList();
    });
  }

  void showAddItemDialog() {
    final dimController = TextEditingController();
    final tipoController = TextEditingController();
    final espessuraController = TextEditingController();
    final marcaController = TextEditingController();
    final corController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adicionar Chapa"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: dimController,
                decoration: const InputDecoration(
                    labelText: "Dimensão (ex: 2750x1830)"),
              ),
              TextField(
                controller: tipoController,
                decoration:
                    const InputDecoration(labelText: "Tipo (ex: Inteira)"),
              ),
              TextField(
                controller: espessuraController,
                decoration:
                    const InputDecoration(labelText: "Espessura (ex: 18mm)"),
              ),
              TextField(
                controller: marcaController,
                decoration:
                    const InputDecoration(labelText: "Marca (ex: Duratex)"),
              ),
              TextField(
                controller: corController,
                decoration:
                    const InputDecoration(labelText: "Cor (ex: Branco)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (dimController.text.isNotEmpty &&
                  tipoController.text.isNotEmpty &&
                  espessuraController.text.isNotEmpty &&
                  marcaController.text.isNotEmpty &&
                  corController.text.isNotEmpty) {
                setState(() {
                  stockItems.add({
                    "dimensao": dimController.text,
                    "tipo": tipoController.text,
                    "espessura": espessuraController.text,
                    "marca": marcaController.text,
                    "cor": corController.text,
                  });
                  _saveStockItems();
                  applyFilter();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  void removeItem(int index) {
    setState(() {
      Map<String, String> itemToRemove = filteredItems[index];
      stockItems.removeWhere((item) =>
          item["dimensao"] == itemToRemove["dimensao"] &&
          item["tipo"] == itemToRemove["tipo"] &&
          item["espessura"] == itemToRemove["espessura"] &&
          item["marca"] == itemToRemove["marca"] &&
          item["cor"] == itemToRemove["cor"]);
      _saveStockItems();
      applyFilter();
    });
  }

  Widget infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildFilterChips(String label, List<String> options,
      String selectedValue, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selectedValue;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (_) {
            onSelected(opt);
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey[300],
          labelStyle:
              TextStyle(color: isSelected ? Colors.white : Colors.black),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }).toList(),
    );
  }

  void openDetailPage(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChapaDetailPage(
                chapa: item,
                onDelete: () {
                  setState(() {
                    stockItems.remove(item);
                    _saveStockItems();
                    applyFilter();
                  });
                  Navigator.pop(context);
                },
                onEdit: (updatedItem) {
                  setState(() {
                    int idx = stockItems.indexOf(item);
                    if (idx != -1) {
                      stockItems[idx] = updatedItem;
                      _saveStockItems();
                      applyFilter();
                    }
                  });
                },
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> tipos = [
      "Todas",
      ...stockItems.map((e) => e["tipo"]!).toSet()
    ];
    List<String> espessuras = [
      "Todas",
      ...stockItems.map((e) => e["espessura"]!).toSet()
    ];
    List<String> marcas = [
      "Todas",
      ...stockItems.map((e) => e["marca"]!).toSet()
    ];
    List<String> cores = ["Todas", ...stockItems.map((e) => e["cor"]!).toSet()];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Current View Title"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, size: 28),
            onPressed: showAddItemDialog,
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0.7,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: buildFilterChips(
                "Tipo",
                tipos,
                tipoFiltro,
                (val) {
                  tipoFiltro = val;
                  applyFilter();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: buildFilterChips(
                "Espessura",
                espessuras,
                espessuraFiltro,
                (val) {
                  espessuraFiltro = val;
                  applyFilter();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: buildFilterChips(
                "Marca",
                marcas,
                marcaFiltro,
                (val) {
                  marcaFiltro = val;
                  applyFilter();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: buildFilterChips(
                "Cor",
                cores,
                corFiltro,
                (val) {
                  corFiltro = val;
                  applyFilter();
                },
              ),
            ),
            filteredItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        "Nenhum item no estoque",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: filteredItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () => openDetailPage(item),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Chapa ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                              text: item["dimensao"] ?? "",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item["tipo"] ?? "",
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          infoColumn("Espessura",
                                              item["espessura"] ?? ""),
                                          infoColumn(
                                              "Marca", item["marca"] ?? ""),
                                          infoColumn("Cor", item["cor"] ?? ""),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => removeItem(index),
                                  icon: Icon(Icons.close,
                                      color: Colors.grey[600], size: 20),
                                  splashRadius: 18,
                                  tooltip: "Remover",
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            label: "Estoque",
          ),
        ],
        onTap: (index) {
          // Navegação futura
        },
      ),
    );
  }
}

// Detalhes da chapa
class ChapaDetailPage extends StatelessWidget {
  final Map<String, String> chapa;
  final VoidCallback onDelete;
  final Function(Map<String, String>) onEdit;

  const ChapaDetailPage({
    Key? key,
    required this.chapa,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void openEditPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditChapaPage(
                chapa: chapa,
                onSave: (updatedChapa) {
                  onEdit(updatedChapa);
                  Navigator.pop(context); // Fecha edição
                  Navigator.pop(context); // Volta para a lista
                },
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da Chapa"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Editar",
            onPressed: () => openEditPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Remover",
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text("Remover Chapa?"),
                  content: const Text(
                      "Deseja realmente remover esta chapa do estoque?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(c);
                        onDelete();
                      },
                      child: const Text("Remover"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chapa ${chapa["dimensao"] ?? ""}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            infoRow("Tipo", chapa["tipo"] ?? ""),
            infoRow("Espessura", chapa["espessura"] ?? ""),
            infoRow("Marca", chapa["marca"] ?? ""),
            infoRow("Cor", chapa["cor"] ?? ""),
          ],
        ),
      ),
    );
  }
}

// Página para editar chapa
class EditChapaPage extends StatefulWidget {
  final Map<String, String> chapa;
  final Function(Map<String, String>) onSave;

  const EditChapaPage({Key? key, required this.chapa, required this.onSave})
      : super(key: key);

  @override
  State<EditChapaPage> createState() => _EditChapaPageState();
}

class _EditChapaPageState extends State<EditChapaPage> {
  late TextEditingController dimController;
  late TextEditingController tipoController;
  late TextEditingController espessuraController;
  late TextEditingController marcaController;
  late TextEditingController corController;

  @override
  void initState() {
    super.initState();
    dimController = TextEditingController(text: widget.chapa["dimensao"]);
    tipoController = TextEditingController(text: widget.chapa["tipo"]);
    espessuraController =
        TextEditingController(text: widget.chapa["espessura"]);
    marcaController = TextEditingController(text: widget.chapa["marca"]);
    corController = TextEditingController(text: widget.chapa["cor"]);
  }

  @override
  void dispose() {
    dimController.dispose();
    tipoController.dispose();
    espessuraController.dispose();
    marcaController.dispose();
    corController.dispose();
    super.dispose();
  }

  void save() {
    if (dimController.text.isEmpty ||
        tipoController.text.isEmpty ||
        espessuraController.text.isEmpty ||
        marcaController.text.isEmpty ||
        corController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, preencha todos os campos")));
      return;
    }

    widget.onSave({
      "dimensao": dimController.text,
      "tipo": tipoController.text,
      "espessura": espessuraController.text,
      "marca": marcaController.text,
      "cor": corController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Chapa"),
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: save,
            icon: const Icon(Icons.check),
            tooltip: "Salvar",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: dimController,
              decoration:
                  const InputDecoration(labelText: "Dimensão (ex: 2750x1830)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tipoController,
              decoration:
                  const InputDecoration(labelText: "Tipo (ex: Inteira)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: espessuraController,
              decoration:
                  const InputDecoration(labelText: "Espessura (ex: 18mm)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: marcaController,
              decoration:
                  const InputDecoration(labelText: "Marca (ex: Duratex)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: corController,
              decoration: const InputDecoration(labelText: "Cor (ex: Branco)"),
            ),
          ],
        ),
      ),
    );
  }
}
