import 'dart:math';
import '../../domain/models/sku_model.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/warehouse_zone_model.dart';
import '../../domain/models/movement_log_model.dart';
import '../../domain/models/alert_model.dart';
import '../../core/constants/app_constants.dart';

class MockDatabase {
  static final MockDatabase instance = MockDatabase._internal();
  factory MockDatabase() => instance;

  late List<SkuModel> skus;
  late List<OrderModel> orders;
  late List<UserModel> users;
  late List<WarehouseZoneModel> zones;
  late List<MovementLogModel> auditLogs;
  late List<AlertModel> alerts;

  MockDatabase._internal() {
    _initData();
  }

  void _initData() {
    final random = Random(42);

    users = [
      UserModel(
        id: 'USR-001',
        name: 'Rajesh Sharma',
        email: 'admin@stocksense.in',
        photoUrl: 'https://i.pravatar.cc/150?img=11',
        role: UserRole.admin,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      UserModel(
        id: 'USR-002',
        name: 'Priya Nair',
        email: 'manager@stocksense.in',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        role: UserRole.warehouseManager,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      UserModel(
        id: 'USR-003',
        name: 'Amit Verma',
        email: 'picker1@stocksense.in',
        photoUrl: 'https://i.pravatar.cc/150?img=12',
        role: UserRole.picker,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UserModel(
        id: 'USR-004',
        name: 'Suresh Patel',
        email: 'dispatch@stocksense.in',
        photoUrl: 'https://i.pravatar.cc/150?img=33',
        role: UserRole.dispatcher,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      UserModel(
        id: 'USR-005',
        name: 'Ananya Roy',
        email: 'viewer@stocksense.in',
        photoUrl: 'https://i.pravatar.cc/150?img=26',
        role: UserRole.viewer,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserModel(
        id: 'USR-006',
        name: 'Vikas Kumar',
        email: 'picker2@stocksense.in',
        photoUrl: 'https://i.pravatar.cc/150?img=68',
        role: UserRole.picker,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    final categories = ['Electronics', 'FMCG', 'Apparel', 'Pharma', 'Hardware', 'Stationery'];
    final skuPrefixes = {
      'Electronics': ['ELEC-BOAT', 'ELEC-SAMS', 'ELEC-PREST', 'ELEC-HAVE', 'ELEC-MI', 'ELEC-PHIL'],
      'FMCG': ['FMCG-TATA', 'FMCG-AMUL', 'FMCG-BRIT', 'FMCG-DAAT', 'FMCG-HIND', 'FMCG-FORT'],
      'Apparel': ['APPR-RAYM', 'APPR-MANY', 'APPR-ALLE', 'APPR-FABI', 'APPR-PUMA', 'APPR-ZARA'],
      'Pharma': ['PHRM-CIPL', 'PHRM-SUNP', 'PHRM-DRRE', 'PHRM-MANK', 'PHRM-GLAX', 'PHRM-ABB'],
      'Hardware': ['HRDW-BOCH', 'HRDW-STAN', 'HRDW-TATA', 'HRDW-ANCH', 'HRDW-CROM', 'HRDW-FINO'],
      'Stationery': ['STAT-CLAS', 'STAT-NATR', 'STAT-CAML', 'STAT-PENT', 'STAT-FABR', 'STAT-KOKU'],
    };

    final productTemplates = {
      'Electronics': [
        'Rockerz 450 Bluetooth Headphones', 'Galaxy M14 5G (6GB RAM)', 'Induction Cooktop 2000W',
        '1.5 sqmm FlameRetardant Wire 90m', '10000mAh Power Bank Fast Charge', 'Electric Kettle 1.8L',
        'Smart LED Bulb 12W RGB', 'Ergonomic Wireless Mouse', 'Mechanical Gaming Keyboard',
        '43-inch 4K Smart TV', 'High Speed Ceiling Fan 1200mm', 'True Wireless Earbuds ANC',
        'Heavy Iron Box 1000W', 'Bluetooth Soundbar 120W', 'Digital Kitchen Scale 10kg',
        'Smart Fitness Band HR', 'Dual Band Wi-Fi 6 Router', 'Multi-plug Surge Protector 4-Way',
        'Emergency LED Lantern', 'Portable Bluetooth Speaker 20W', 'Trim & Style Beard Trimmer',
        'Mixer Grinder 750W 3 Jars', 'Water Purifier RO+UV 7L', 'Hair Dryer 1600W Compact',
        '20000mAh Power Bank Heavy Duty', 'Action Camera 4K Ultra HD'
      ],
      'FMCG': [
        'Vacuum Evaporated Iodized Salt 1kg', 'Pasteurized Butter 500g Pack', 'Good Day Cashew Cookies 600g',
        'Basmati Rice Rozana 5kg', 'Surf Excel Easy Wash Powder 1kg', 'Fortune Sunflower Oil 5L Can',
        'Chyawanprash Awaleha 1kg', 'Maggi 2-Minute Noodles 12-Pack', 'Dettol Antiseptic Liquid 500ml',
        'Red Label Strong Tea 500g', 'Cadbury Dairy Milk Silk 150g', 'Patanjali Whole Wheat Atta 10kg',
        'Parle-G Gold Biscuits 800g', 'Colgate Strong Teeth Paste 200g', 'Dove Cream Beauty Bar 125g x 3',
        'Nescafe Classic Coffee 200g Glass Jar', 'Catch Super Garam Masala 100g', 'Saffola Gold Oil 5L',
        'Lays Magic Masala Chips 10-Pack', 'Tropicana 100% Orange Juice 1L', 'Vim Dishwash Liquid 750ml',
        'Harpic Power Plus Cleaner 1L', 'Aashirvaad Shuddh Chakki Atta 5kg', 'Kissan Mixed Fruit Jam 700g',
        'Lipton Green Tea Honey Lemon 100 Bags'
      ],
      'Apparel': [
        'Premium Formal Cotton Shirt White L', 'Kurta Pajama Silk Blend Festive', 'Allen Solly Slim Fit Chinos 32',
        'FabIndia Cotton Short Kurta XL', 'Puma Essential Running Shoes 9', 'Casual Denim Jacket Dark Blue M',
        'Formal Leather Belt Tan Brown', 'Polo Collar T-Shirt Navy Blue', 'Track Pants Dri-Fit Black L',
        'Saree Kanjeevaram Art Silk Red', 'Leather Formal Oxford Shoes 8', 'Cotton Crew Socks Pack of 5',
        'Thermal Top & Bottom Set Gray L', 'Windcheater Hooded Jacket Black', 'Graphic Printed Hoodie XL',
        'Women Cotton Anarkali Suit Set', 'Chiffon Printed Dupatta Yellow', 'Men Cargo Trousers Olive Green 34',
        'Sports Bra High Support M', 'Lightweight Running Shorts Black', 'Pajama Bottoms Soft Rayon Blue',
        'Formal Blazer Slim Fit Dark Gray 40', 'Leather Wallet RFID Blocking Brown', 'Sun Visor Cap Black'
      ],
      'Pharma': [
        'Paracetamol 650mg Tablets 15s', 'Revital H Daily Health Supplement 60s', 'Crocin Pain Relief Tablets 10s',
        'Mankind Multivitamin Gummies 30s', 'Vicks VapoRub Balm 50g Jar', 'Volini Instant Pain Relief Spray 100g',
        'Zincovit Syrup 200ml Bottle', 'Eviol Vitamin E 400mg Capsules 20s', 'Betadine Antiseptic Ointment 20g',
        'ORS Hydration Electrolyte Powder 50g', 'Electral Energy Powder 21.8g x 10', 'Thermometer Digital Waterproof',
        'Pulse Oximeter Fingertip OLED', 'Blood Pressure Monitor Automatic', 'N95 Respirator Mask Pack of 5',
        'Hand Sanitizer Gel 500ml Pump', 'Cough Syrup Honey Cough 100ml', 'Calcium + Vitamin D3 Tablets 30s',
        'Dettol Antiseptic Wipes 40s', 'Band-Aid Washproof Strips Box of 50', 'Pain Relief Gel 30g Tube',
        'Strepsils Lozenges Orange Box 24s', 'Eye Drops Lubricating 10ml', 'Inhaler Vicks Pocket Size'
      ],
      'Hardware': [
        'Cordless Drill Driver 12V Kit', 'Professional Combination Pliers 8-inch', 'High Tensile Hex Bolts M8 x 50mm 100s',
        'Anchor 16A Modular Switch White', 'Crompton 1HP Monoblock Water Pump', 'Finolex PVC Conduit Pipe 25mm 3m',
        'Adjustable Wrench Chrome Finish 10-inch', 'Measuring Tape Auto-Lock 5m', 'Electric Soldering Iron 60W',
        'Heavy Duty Padlock Brass 60mm', 'Wire Stripper & Cutter Multi-Tool', 'Hammer Steel Handle 500g',
        'Screw Driver Set 8-in-1 Magnetic', 'Wall Plugs Rawl Plugs 6mm Pack of 200', 'Teflon Thread Seal Tape 12mm x 10m',
        'Safety Goggles Clear Anti-Scratch', 'Work Gloves Cut Resistant XL', 'Spirit Level Aluminum 24-inch',
        'Angle Grinder 850W 4-inch', 'Stainless Steel Door Hinge 4-inch Pair'
      ],
      'Stationery': [
        'Pulse Spiral Notebook 300 Pages 6-Pack', 'Classic Ball Pens Blue Box of 20', 'Camel Acrylic Color Set 12 Tubes',
        'Pentel EnerGel Liquid Gel Pen 0.7mm', 'Faber-Castell Highlighter Set 4 Colors', 'Kokuyo Camlin Geometry Box',
        'A4 Copier Paper 80GSM 500 Sheets Ream', 'Sticky Notes 3x3 Inch Neon Pack of 5', 'Correction Tape Roller 12m',
        'Heavy Duty Stapler 100 Sheet Capacity', 'Staple Pins 24/6 Box of 1000', 'Paper Clips Vinyl Coated Box 100',
        'Document Mesh Folder A4 Zipper 5-Pack', 'Permanent Marker Black Box of 10', 'Whiteboard Marker Assorted 4-Pack',
        'Calculators Scientific 417 Functions', 'Executive Diary Leatherette 2026', 'Correction Pen Metal Tip 7ml',
        'Double Sided Foam Tape 24mm x 5m', 'Scissors Heavy Duty 8-inch Stainless'
      ],
    };

    skus = [];
    int globalIndex = 1001;

    for (var cat in categories) {
      final names = productTemplates[cat]!;
      final prefixes = skuPrefixes[cat]!;

      for (int i = 0; i < names.length; i++) {
        final prefix = prefixes[i % prefixes.length];
        final skuCode = '$prefix-${100 + i}';
        final barcode = '890${random.nextInt(899999999) + 100000000}';
        final qty = random.nextInt(220);
        final reorder = 20 + random.nextInt(30);
        final maxCap = 250 + random.nextInt(100);

        final zone = AppConstants.zones[i % AppConstants.zones.length];
        final aisle = 'A-0${(i % 6) + 1}';
        final rack = 'R-${(i % 5) + 1}';
        final bin = 'B-${(i % 8) + 1}';

        double price = 50 + (random.nextDouble() * 2500);
        if (cat == 'Electronics') price += 2000;
        if (cat == 'Hardware') price += 500;
        price = (price * 10).roundToDouble() / 10;

        List<int> history = [];
        int current = qty;
        for (int h = 0; h < 6; h++) {
          history.insert(0, (current + random.nextInt(40) - 20).clamp(0, maxCap));
        }
        history.add(qty);

        skus.add(
          SkuModel(
            id: 'SKU-$globalIndex',
            skuCode: skuCode,
            barcode: barcode,
            name: names[i],
            category: cat,
            unitPrice: price,
            quantity: qty,
            reorderLevel: reorder,
            maxCapacity: maxCap,
            zone: zone,
            aisle: aisle,
            rack: rack,
            bin: bin,
            imageUrl: 'https://picsum.photos/seed/$skuCode/300/300',
            description: 'High-grade commercial stock item: ${names[i]}. Formulated for supply chain distribution in India.',
            stockHistory: history,
            updatedAt: DateTime.now().subtract(Duration(hours: random.nextInt(48))),
          ),
        );
        globalIndex++;
      }
    }

    zones = [
      WarehouseZoneModel(
        id: 'Z-01',
        name: 'Zone A - Electronics & High-Value',
        code: 'Zone A',
        totalCapacity: 5000,
        currentOccupancy: 3850,
        x: 0.05,
        y: 0.05,
        width: 0.42,
        height: 0.42,
        racks: List.generate(
          6,
          (i) => RackModel(
            id: 'RA-${i + 1}',
            code: 'Rack A${i + 1}',
            capacity: 850,
            currentItems: 500 + random.nextInt(300),
            skuIds: skus.where((s) => s.zone == 'Zone A').take(4).map((s) => s.id).toList(),
          ),
        ),
      ),
      WarehouseZoneModel(
        id: 'Z-02',
        name: 'Zone B - FMCG & Consumables',
        code: 'Zone B',
        totalCapacity: 8000,
        currentOccupancy: 7420,
        x: 0.53,
        y: 0.05,
        width: 0.42,
        height: 0.42,
        racks: List.generate(
          6,
          (i) => RackModel(
            id: 'RB-${i + 1}',
            code: 'Rack B${i + 1}',
            capacity: 1330,
            currentItems: 1100 + random.nextInt(200),
            skuIds: skus.where((s) => s.zone == 'Zone B').take(4).map((s) => s.id).toList(),
          ),
        ),
      ),
      WarehouseZoneModel(
        id: 'Z-03',
        name: 'Zone C - Apparel & Textiles',
        code: 'Zone C',
        totalCapacity: 6000,
        currentOccupancy: 3900,
        x: 0.05,
        y: 0.53,
        width: 0.42,
        height: 0.42,
        racks: List.generate(
          6,
          (i) => RackModel(
            id: 'RC-${i + 1}',
            code: 'Rack C${i + 1}',
            capacity: 1000,
            currentItems: 600 + random.nextInt(250),
            skuIds: skus.where((s) => s.zone == 'Zone C').take(4).map((s) => s.id).toList(),
          ),
        ),
      ),
      WarehouseZoneModel(
        id: 'Z-04',
        name: 'Zone D - Pharma & Hardware Bulk',
        code: 'Zone D',
        totalCapacity: 7000,
        currentOccupancy: 4200,
        x: 0.53,
        y: 0.53,
        width: 0.42,
        height: 0.42,
        racks: List.generate(
          6,
          (i) => RackModel(
            id: 'RD-${i + 1}',
            code: 'Rack D${i + 1}',
            capacity: 1160,
            currentItems: 650 + random.nextInt(300),
            skuIds: skus.where((s) => s.zone == 'Zone D').take(4).map((s) => s.id).toList(),
          ),
        ),
      ),
    ];

    final customerNames = [
      'Reliance Retail Bengaluru Hub', 'Blinkit Fulfillment Center Gurgaon',
      'Zepto Store Indiranagar', 'Amazon Fulfillment Warehouse Pune',
      'Flipkart Mother Hub Bhiwandi', 'Apollo Pharmacy Main Depot Chennai'
    ];

    final addresses = [
      'Plot 42, Electronic City Phase 1, Bengaluru, Karnataka 560100',
      'Sector 37, Pace City II, Gurgaon, Haryana 122001',
    ];

    orders = [];
    final statuses = [
      OrderStatus.pending,
      OrderStatus.picking,
      OrderStatus.packed,
      OrderStatus.dispatched,
      OrderStatus.delivered
    ];

    for (int o = 1; o <= 30; o++) {
      final status = statuses[o % statuses.length];
      final orderSkus = (skus..shuffle(random)).take(3 + random.nextInt(4)).toList();

      final lineItems = orderSkus.map((s) {
        final req = 5 + random.nextInt(25);
        int picked = 0;
        if (status == OrderStatus.picking) picked = random.nextInt(req);
        if (status == OrderStatus.packed || status == OrderStatus.dispatched || status == OrderStatus.delivered) {
          picked = req;
        }

        return OrderLineItem(
          skuId: s.id,
          skuCode: s.skuCode,
          skuName: s.name,
          expectedQty: req,
          pickedQty: picked,
          location: s.fullLocation,
          isConfirmed: picked == req,
        );
      }).toList();

      orders.add(
        OrderModel(
          id: 'ORD-$o',
          orderNumber: 'SO-2026-${1000 + o}',
          customerName: customerNames[o % customerNames.length],
          shippingAddress: addresses[o % addresses.length],
          items: lineItems,
          status: status,
          createdAt: DateTime.now().subtract(Duration(hours: o * 3)),
        ),
      );
    }

    auditLogs = [];
    final usersList = ['admin@stocksense.in', 'manager@stocksense.in', 'picker1@stocksense.in', 'dispatch@stocksense.in'];
    final devices = ['Zebra TC52 Scanner', 'Honeywell EDA51 Terminal', 'iPad Control Station'];

    for (int m = 1; m <= 210; m++) {
      final sku = skus[m % skus.length];
      final mType = MovementType.values[m % MovementType.values.length];
      final qty = 5 + random.nextInt(40);
      final before = 20 + random.nextInt(100);
      final after = mType == MovementType.inward ? before + qty : (before - qty).clamp(0, 500);

      auditLogs.add(
        MovementLogModel(
          id: 'MOV-${2000 + m}',
          timestamp: DateTime.now().subtract(Duration(hours: m * 2)),
          type: mType,
          skuId: sku.id,
          skuCode: sku.skuCode,
          skuName: sku.name,
          quantity: qty,
          beforeQty: before,
          afterQty: after,
          fromLocation: sku.fullLocation,
          toLocation: sku.fullLocation,
          performedBy: usersList[m % usersList.length],
          referenceNumber: 'REF-${8000 + m}',
          device: devices[m % devices.length],
        ),
      );
    }

    alerts = [];
    final lowStockSkus = skus.where((s) => s.quantity <= s.reorderLevel).toList();
    for (int a = 0; a < lowStockSkus.length; a++) {
      final s = lowStockSkus[a];
      alerts.add(
        AlertModel(
          id: 'ALT-${100 + a}',
          title: s.quantity <= (s.reorderLevel / 2) ? 'Critical Stock Level' : 'Low Stock Threshold Warning',
          message: '${s.name} (${s.skuCode}) has only ${s.quantity} units left in ${s.fullLocation}.',
          severity: s.quantity <= (s.reorderLevel / 2) ? AlertSeverity.critical : AlertSeverity.warning,
          skuId: s.id,
          skuCode: s.skuCode,
          createdAt: DateTime.now().subtract(Duration(hours: a * 4)),
        ),
      );
    }
  }
}
