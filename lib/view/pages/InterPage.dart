part of 'pages.dart';

class InterPage extends StatefulWidget{
  const InterPage({super.key});

  @override
  State<InterPage> createState() => _InterPageState();
}

class _InterPageState extends State<InterPage> {

  late HomeViewModel homeViewModel;

  final _weightController = TextEditingController();
  final _destinationController = TextEditingController();

  String _selectedCourier = 'jne';
  final List<String> _couriersOptions = ['jne', 'pos', 'tiki'];
  int? _selectedProvinceOriginId;
  int? _selectedCityOriginId;
  String? _selectDestination;

  @override
  void initState(){
    super.initState();
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    if (homeViewModel.provinceList.status == Status.notStarted) {
      homeViewModel.getProvinceList();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _destinationController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => interViewModel(),
      child: Scaffold(
        body: Consumer<interViewModel>(
          builder: (context, interViewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Kurir", style: TextStyle(fontWeight: FontWeight.bold)),
                            DropdownButtonFormField<String>(
                              value: _selectedCourier,
                              isExpanded: true,
                              items: _couriersOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() => _selectedCourier = newValue!);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Input Berat
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Berat (gr)", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "e.g. 1000",
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  const Text("Origin (Indonesia)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  
                  // Dropdown Provinsi Asal
                  Consumer<HomeViewModel>(
                    builder: (context, homeVM, _) {
                       if (homeVM.provinceList.status == Status.loading) {
                        return const LinearProgressIndicator();
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedProvinceOriginId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Pilih Provinsi"),
                        items: homeVM.provinceList.data?.map((p) {
                          return DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name ?? ""),
                          );
                        }).toList(),
                        onChanged: (newId) {
                          setState(() {
                            _selectedProvinceOriginId = newId;
                            _selectedCityOriginId = null; // Reset kota
                          });
                          // Load Kota berdasarkan Provinsi
                          if (newId != null) {
                            homeVM.getCityOriginList(newId);
                          }
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),

                  // Dropdown Kota Asal
                  Consumer<HomeViewModel>(
                    builder: (context, homeVM, _) {
                       if (homeVM.cityOriginList.status == Status.loading) {
                        return const LinearProgressIndicator();
                      }
                      
                      // Cek validasi agar tidak error dropdown value
                      final cities = homeVM.cityOriginList.data ?? [];
                      final validIds = cities.map((c) => c.id).toSet();
                      final validValue = validIds.contains(_selectedCityOriginId) ? _selectedCityOriginId : null;

                      return DropdownButtonFormField<int>(
                        value: validValue,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Pilih Kota"),
                        items: cities.map((c) {
                          return DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name ?? ""),
                          );
                        }).toList(),
                        onChanged: (newId) {
                          setState(() => _selectedCityOriginId = newId);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- BAGIAN 3: DESTINATION (INTERNATIONAL) ---
                  const Text("Destination (International)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  
                  // Search Bar Negara
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: "Cari negara (min 3 karakter)",
                      border: const OutlineInputBorder(),
                      suffixIcon: _destinationController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _destinationController.clear();
                              setState(() => _selectDestination = null);
                              interViewModel.setCountryList(ApiResponse.notStarted());
                            },
                          )
                        : const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // Trigger search di ViewModel
                      if (value.length >= 3) {
                        interViewModel.getCountryList(query: value);
                      }
                    },
                  ),

                  // List Suggestion Negara (Muncul di bawah search bar)
                  if (interViewModel.countryList.status == Status.completed && 
                      _selectDestination == null && 
                      _destinationController.text.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: interViewModel.countryList.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final country = interViewModel.countryList.data![index];
                          return ListTile(
                            title: Text(country.countryName ?? "-"),
                            onTap: () {
                              setState(() {
                                _selectDestination = country.countryId; // Simpan ID Negara
                                _destinationController.text = country.countryName ?? ""; // Tampilkan Nama
                              });
                              // Sembunyikan list
                              interViewModel.setCountryList(ApiResponse.notStarted()); 
                            },
                          );
                        },
                      ),
                    ),
                  
                  if (interViewModel.countryList.status == Status.loading)
                     const Padding(
                       padding: EdgeInsets.only(top: 8.0),
                       child: LinearProgressIndicator(),
                     ),

                  const SizedBox(height: 24),

                  // --- BUTTON HITUNG ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validasi Input
                        if (_selectedCityOriginId == null || 
                            _selectDestination == null || 
                            _weightController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Mohon lengkapi data (Kota Asal, Negara Tujuan, Berat)")),
                          );
                          return;
                        }

                        // Panggil API Hitung Cost
                        interViewModel.checkInterCost(
                          origin: _selectedCityOriginId.toString(), // ID Kota (konvert ke String)
                          destinationCountryId: _selectDestination!, // ID Negara
                          weight: int.parse(_weightController.text),
                          courier: _selectedCourier,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: interViewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Hitung Ongkir Internasional", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 24),

                    if (interViewModel.interCostList.status == Status.completed)
                     ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: interViewModel.interCostList.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final cost = interViewModel.interCostList.data![index];
                          return CardInterCost(cost);
                        },
                     ),
                     
                  if (interViewModel.interCostList.status == Status.error)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "Error: ${interViewModel.interCostList.message}", 
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        )
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}