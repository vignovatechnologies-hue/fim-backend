import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _service;

  String _currentLanguageCode = 'en';
  List<Map<String, dynamic>> _supportedLanguages = [];
  Map<String, String> _activeDictionary = {};
  Map<String, String> _englishFallbackDictionary = {};
  bool _isLoading = false;

  LocalizationProvider(this._service) {
    init();
  }

  String get currentLanguageCode => _currentLanguageCode;
  List<Map<String, dynamic>> get supportedLanguages => _supportedLanguages;
  bool get isLoading => _isLoading;

  Locale get currentLocale => Locale(_currentLanguageCode);

  static const Map<String, Map<String, String>> _bundledTranslations = {
    "en": {
      "app.name": "FIM",
      "app.subtitle": "Financial Intelligence & Smart EMI Manager",
      "welcome.title": "Welcome to FIM",
      "select.language": "Select Language",
      "continue": "Continue",
      "sign.in": "Sign In",
      "signing.in": "Signing In...",
      "sign.up": "Sign Up",
      "email": "Email Address",
      "password": "Password",
      "forgot.password": "Forgot Password?",
      "remember.me": "Save Password",
      "dont.have.account": "Don't have an account? ",
      "create.account": "Create Account",
      "try.again": "Try Again",
      "invalid.credentials": "Invalid Credentials",
      "sign.in.failed": "Sign In Failed",
      
      // Navigation
      "nav.overview": "Overview",
      "nav.expenses": "Expenses",
      "nav.emis": "EMIs",
      "nav.savings": "Savings",
      "nav.insights": "AI Insights",
      "nav.profile": "Profile",

      // Dashboard
      "dashboard.hub": "Your Financial Intelligence Hub",
      "dashboard.hello": "Hello",
      "total.net.balance": "Total Net Balance",
      "protected": "Protected",
      "monthly.income": "Monthly Income",
      "monthly.expenses": "Monthly Expenses",
      "total.outstanding.debt": "Total Debt",
      "across.all.loans": "Across all loans",
      "monthly.emi.total": "Monthly EMI Due",
      "this.billing.cycle": "This billing cycle",
      "accumulated.savings": "Accumulated Savings",
      "safe.reserve": "Safe reserve",
      "active.goals": "Active Goals",
      "in.progress": "In progress",
      "upcoming.emis": "Upcoming EMIs",
      "active.count": "Active",
      "recent.activity": "Recent Activity",
      "latest.count": "Latest",
      "no.transactions": "No transactions yet. Start logging expenses or income!",
      "health.score": "Financial Health Score",

      // EMIs & Loans
      "emis.title": "EMIs & Loans",
      "emis.subtitle": "Manage your loans and track all your EMI obligations",
      "total.monthly.obligation": "Total Monthly Obligation",
      "total.outstanding": "Total Outstanding",
      "add.loan": "Add Loan / EMI",
      "save.loan": "Save Loan Details",
      "delete.loan_title": "Delete Loan Record?",
      "delete.loan_msg": "Are you sure you want to delete this loan? All associated EMI payment history will be removed.",
      "no.loans": "No active loans found. Tap + to add your first EMI/Loan.",

      // Transactions
      "transactions.title": "Expenses & Income",
      "transactions.subtitle": "Track and categorize your spending",
      "tab.all": "All",
      "tab.expenses": "Expenses",
      "tab.income": "Income",
      "add.transaction": "Add Expense / Income",
      "download.statement": "Download Statement",
      "statement.subtitle": "Select timeframe or choose a custom date range for day-wise financial statement.",
      "statement.daily": "Daily (Today)",
      "statement.weekly": "Weekly (Last 7 Days)",
      "statement.monthly": "Monthly (Current Month)",
      "statement.yearly": "Yearly (Current Year)",
      "statement.custom": "Custom Date Range",
      "download.excel": "Download Excel (.xlsx)",
      "download.pdf": "Download PDF (.pdf)",
      "no.transactions_found": "No transactions found for the selected filter.",

      // Savings
      "savings.title": "Savings & Goals",
      "savings.subtitle": "Track and manage your savings goals",
      "total.savings.reserve": "Total Savings Reserve",
      "add.goal": "Create Custom Goal",
      "edit.goal": "Edit Savings Goal",
      "deposit": "Deposit",
      "deposit.amount": "Deposit Amount (₹)",
      "confirm.deposit": "Confirm Deposit",
      "saved": "Saved",
      "target": "Target",
      "no.goals": "No savings goals set yet. Tap + to start saving for your dreams!",

      // AI Insights
      "insights.title": "AI Financial Copilot",
      "insights.disclaimer": "FIM AI Assistant is in active beta. Insights are calculated live from your budgets & EMIs.",
      "insights.ask_placeholder": "Ask anything about your loans or expenses...",
      "insights.send": "Send",

      // Profile & Settings
      "profile.title": "My Profile & Settings",
      "profile.subtitle": "Manage your profile, accounts & preferences",
      "profile.change_photo": "Change Photo",
      "profile.linked_banks": "Linked Bank Accounts",
      "profile.add_bank": "Add Bank",
      "profile.no_banks": "No bank accounts linked yet.",
      "profile.no_banks_sub": "Add your bank account to track transactions.",
      "settings.compliance": "Settings & Compliance",
      "language.preference": "App Language",
      "language.preference_sub": "Change app language (English, हिन्दी, తెలుగు)",
      "privacy.policy": "Privacy Policy",
      "privacy.policy_sub": "Read our privacy policy",
      "terms.of.use": "Terms of Use",
      "terms.of.use_sub": "Read our terms and conditions",
      "emi.reminders": "EMI Reminder Notifications",
      "emi.reminders_enabled": "Enabled • Daily reminders active",
      "emi.reminders_disabled": "Disabled",
      "sign.out": "Sign Out",
      "delete.account": "Delete Account",
      "dialog.sign_out_title": "Sign Out",
      "dialog.sign_out_msg": "Are you sure you want to sign out of SMART-EMI?",
      "dialog.delete_account_title": "Delete Account",
      "dialog.delete_account_msg": "Are you sure you want to delete your account? This action is permanent.",
      "cancel": "Cancel",
      "save": "Save Changes",
      "delete": "Delete",
    },
    "hi": {
      "app.name": "FIM",
      "app.subtitle": "वित्तीय बुद्धिमत्ता और स्मार्ट ईएमआई प्रबंधक",
      "welcome.title": "FIM में आपका स्वागत है",
      "select.language": "भाषा चुनें",
      "continue": "जारी रखें",
      "sign.in": "साइन इन करें",
      "signing.in": "साइन इन हो रहा है...",
      "sign.up": "साइन अप करें",
      "email": "ईमेल पता",
      "password": "पासवर्ड",
      "forgot.password": "पासवर्ड भूल गए?",
      "remember.me": "पासवर्ड सहेजें",
      "dont.have.account": "खाता नहीं है? ",
      "create.account": "खाता बनाएं",
      "try.again": "पुनः प्रयास करें",
      "invalid.credentials": "अमान्य क्रेडेंशियल",
      "sign.in.failed": "साइन इन विफल",
      
      // Navigation
      "nav.overview": "डैशबोर्ड",
      "nav.expenses": "खर्च",
      "nav.emis": "EMI",
      "nav.savings": "बचत",
      "nav.insights": "AI अंतर्दृष्टि",
      "nav.profile": "प्रोफ़ाइल",

      // Dashboard
      "dashboard.hub": "आपका वित्तीय बुद्धिमत्ता केंद्र",
      "dashboard.hello": "नमस्ते",
      "total.net.balance": "कुल नेट बैलेंस",
      "protected": "सुरक्षित",
      "monthly.income": "मासिक आय",
      "monthly.expenses": "मासिक खर्च",
      "total.outstanding.debt": "कुल बकाया ऋण",
      "across.all.loans": "सभी ऋणों पर",
      "monthly.emi.total": "मासिक EMI बकाया",
      "this.billing.cycle": "इस बिलिंग चक्र",
      "accumulated.savings": "संचित बचत",
      "safe.reserve": "सुरक्षित बचत",
      "active.goals": "सक्रिय लक्ष्य",
      "in.progress": "प्रगति में",
      "upcoming.emis": "आगामी EMI",
      "active.count": "सक्रिय",
      "recent.activity": "हाल की गतिविधि",
      "latest.count": "नवीनतम",
      "no.transactions": "अभी कोई लेन-देन नहीं है। खर्च या आय दर्ज करना शुरू करें!",
      "health.score": "वित्तीय स्वास्थ्य स्कोर",

      // EMIs & Loans
      "emis.title": "EMI और ऋण",
      "emis.subtitle": "अपने ऋणों का प्रबंधन करें और EMI दायित्वों को ट्रैक करें",
      "total.monthly.obligation": "कुल मासिक दायित्व",
      "total.outstanding": "कुल बकाया",
      "add.loan": "ऋण जोड़ें",
      "save.loan": "ऋण विवरण सेव करें",
      "delete.loan_title": "ऋण रिकॉर्ड हटाएं?",
      "delete.loan_msg": "क्या आप वाकई इस ऋण को हटाना चाहते हैं? सभी EMI भुगतान इतिहास हटा दिया जाएगा।",
      "no.loans": "कोई सक्रिय ऋण नहीं मिला। पहला ऋण जोड़ने के लिए + दबाएं।",

      // Transactions
      "transactions.title": "खर्च और आय",
      "transactions.subtitle": "अपने खर्च को ट्रैक और वर्गीकृत करें",
      "tab.all": "सभी",
      "tab.expenses": "खर्च",
      "tab.income": "आय",
      "add.transaction": "खर्च/आय जोड़ें",
      "download.statement": "स्टेटमेंट डाउनलोड करें",
      "statement.subtitle": "वित्तीय विवरण के लिए समय अवधि या कस्टम तिथि सीमा चुनें।",
      "statement.daily": "दैनिक (आज)",
      "statement.weekly": "साप्ताहिक (पिछले 7 दिन)",
      "statement.monthly": "मासिक (वर्तमान माह)",
      "statement.yearly": "वार्षिक (वर्तमान वर्ष)",
      "statement.custom": "कस्टम तिथि सीमा",
      "download.excel": "Excel डाउनलोड करें (.xlsx)",
      "download.pdf": "PDF डाउनलोड करें (.pdf)",
      "no.transactions_found": "चयनित फ़िल्टर के लिए कोई लेन-देन नहीं मिला।",

      // Savings
      "savings.title": "बचत और लक्ष्य",
      "savings.subtitle": "अपने बचत लक्ष्यों को ट्रैक और प्रबंधित करें",
      "total.savings.reserve": "कुल बचत रिजर्व",
      "add.goal": "नया लक्ष्य बनाएं",
      "edit.goal": "बचत लक्ष्य संपादित करें",
      "deposit": "जमा करें",
      "deposit.amount": "जमा राशि (₹)",
      "confirm.deposit": "जमा की पुष्टि करें",
      "saved": "सहेजा गया",
      "target": "लक्ष्य",
      "no.goals": "अभी तक कोई बचत लक्ष्य निर्धारित नहीं है। + दबाकर शुरुआत करें!",

      // AI Insights
      "insights.title": "AI वित्तीय सलाहकार",
      "insights.disclaimer": "FIM AI सहायक सक्रिय बीटा में है। अंतर्दृष्टि आपके बजट और EMI से लाइव निकाली जाती है।",
      "insights.ask_placeholder": "अपने ऋण या खर्च के बारे में कुछ भी पूछें...",
      "insights.send": "भेजें",

      // Profile & Settings
      "profile.title": "प्रोफ़ाइल और सेटिंग्स",
      "profile.subtitle": "अपनी प्रोफ़ाइल, खाते और प्राथमिकताएं प्रबंधित करें",
      "profile.change_photo": "फ़ोटो बदलें",
      "profile.linked_banks": "लिंक किए गए बैंक खाते",
      "profile.add_bank": "बैंक जोड़ें",
      "profile.no_banks": "अभी तक कोई बैंक खाता लिंक नहीं है।",
      "profile.no_banks_sub": "लेन-देन ट्रैक करने के लिए अपना बैंक खाता जोड़ें।",
      "settings.compliance": "सेटिंग्स और अनुपालन",
      "language.preference": "ऐप की भाषा",
      "language.preference_sub": "ऐप की भाषा बदलें (English, हिन्दी, తెలుగు)",
      "privacy.policy": "गोपनीयता नीति",
      "privacy.policy_sub": "हमारी गोपनीयता नीति पढ़ें",
      "terms.of.use": "उपयोग की शर्तें",
      "terms.of.use_sub": "हमारे नियम और शर्तें पढ़ें",
      "emi.reminders": "EMI रिमाइंडर सूचनाएं",
      "emi.reminders_enabled": "सक्रिय • दैनिक अनुस्मारक चालू हैं",
      "emi.reminders_disabled": "अक्षम",
      "sign.out": "साइन आउट",
      "delete.account": "खाता हटाएं",
      "dialog.sign_out_title": "साइन आउट करें",
      "dialog.sign_out_msg": "क्या आप वाकई SMART-EMI से साइन आउट करना चाहते हैं?",
      "dialog.delete_account_title": "खाता हटाएं",
      "dialog.delete_account_msg": "क्या आप सुनिश्चित हैं? आपका सभी ऋण, बचत और खर्च का डेटा स्थायी रूप से हटा दिया जाएगा।",
      "cancel": "रद्द करें",
      "save": "सहेजें",
      "delete": "हटाएं",
    },
    "te": {
      "app.name": "FIM",
      "app.subtitle": "ఆర్థిక మేధస్సు & స్మార్ట్ EMI నిర్వాహకుడు",
      "welcome.title": "FIMకి స్వాగతం",
      "select.language": "భాషను ఎంచుకోండి",
      "continue": "కొనసాగించండి",
      "sign.in": "సైన్ ఇన్",
      "signing.in": "సైన్ ఇన్ అవుతోంది...",
      "sign.up": "సైన్ అప్",
      "email": "ఇమెయిల్ చిరునామా",
      "password": "పాస్‌వర్డ్",
      "forgot.password": "పాస్‌వర్డ్ మర్చిపోయారా?",
      "remember.me": "పాస్‌వర్డ్‌ను సేవ్ చేయండి",
      "dont.have.account": "ఖాతా లేదా? ",
      "create.account": "ఖాతాను సృష్టించండి",
      "try.again": "మళ్ళీ ప్రయత్నించండి",
      "invalid.credentials": "చెల్లని వివరాలు",
      "sign.in.failed": "సైన్ ఇన్ విఫలమైంది",
      
      // Navigation
      "nav.overview": "డ్యాష్‌బోర్డ్",
      "nav.expenses": "లావాదేవీలు",
      "nav.emis": "EMIలు",
      "nav.savings": "పొదుపులు",
      "nav.insights": "AI అంతర్దృష్టులు",
      "nav.profile": "ప్రొఫైల్",

      // Dashboard
      "dashboard.hub": "మీ ఆర్థిక మేధస్సు కేంద్రం",
      "dashboard.hello": "నమస్తే",
      "total.net.balance": "మొత్తం నికర బ్యాలెన్స్",
      "protected": "రక్షించబడింది",
      "monthly.income": "నెలవారీ ఆదాయం",
      "monthly.expenses": "నెలవారీ ఖర్చులు",
      "total.outstanding.debt": "మొత్తం బకాయి రుణం",
      "across.all.loans": "అన్ని రుణాలలో",
      "monthly.emi.total": "నెలవారీ EMI బకాయి",
      "this.billing.cycle": "ఈ బిల్లింగ్ చక్రం",
      "accumulated.savings": "సేకరించిన పొదుపు",
      "safe.reserve": "సురక్షిత నిల్వ",
      "active.goals": "క్రియాశీల లక్ష్యాలు",
      "in.progress": "పురోగతిలో ఉంది",
      "upcoming.emis": "రాబోయే EMIలు",
      "active.count": "క్రియాశీలం",
      "recent.activity": "ఇటీవలి కార్యాచరణ",
      "latest.count": "తాజా",
      "no.transactions": "ఇంకా లావాదేవీలు లేవు. ఖర్చులు లేదా ఆదాయాన్ని నమోదు చేయడం ప్రారంభించండి!",
      "health.score": "ఆర్థిక ఆరోగ్య స్కోరు",

      // EMIs & Loans
      "emis.title": "EMIలు & రుణాలు",
      "emis.subtitle": "మీ రుణాలను నిర్వహించండి మరియు EMI బాధ్యతలను ట్రాక్ చేయండి",
      "total.monthly.obligation": "మొత్తం నెలవారీ బాధ్యత",
      "total.outstanding": "మొత్తం బకాయి",
      "add.loan": "రుణాన్ని జోడించండి",
      "save.loan": "రుణ వివరాలను సేవ్ చేయండి",
      "delete.loan_title": "రుణ రికార్డును తొలగించాలా?",
      "delete.loan_msg": "మీరు ఖచ్చితంగా ఈ రుణాన్ని తొలగించాలనుకుంటున్నారా? సంబంధిత EMI చెల్లింపు చరిత్ర మొత్తం తీసివేయబడుతుంది.",
      "no.loans": "క్రియాశీల రుణాలు ఏవీ కనుగొనబడలేదు. మొదటి రుణాన్ని జోడించడానికి + నొక్కండి.",

      // Transactions
      "transactions.title": "ఖర్చులు & ఆదాయం",
      "transactions.subtitle": "మీ ఖర్చులను ట్రాక్ చేసి వర్గీకరించండి",
      "tab.all": "అన్నీ",
      "tab.expenses": "ఖర్చులు",
      "tab.income": "ఆదాయం",
      "add.transaction": "ఖర్చు/ఆదాయం జోడించండి",
      "download.statement": "స్టేట్‌మెంట్‌ను డౌన్‌లోడ్ చేయండి",
      "statement.subtitle": "ఆర్థిక స్టేట్‌మెంట్ కోసం కాలపరిమితిని ఎంచుకోండి.",
      "statement.daily": "రోజువారీ (ఈరోజు)",
      "statement.weekly": "వారంవారీ (గత 7 రోజులు)",
      "statement.monthly": "నెలవారీ (ప్రస్తుత నెల)",
      "statement.yearly": "వార్షిక (ప్రస్తుత సంవత్సరం)",
      "statement.custom": "కస్టమ్ తేదీ పరిధి",
      "download.excel": "Excel డౌన్‌లోడ్ చేయండి (.xlsx)",
      "download.pdf": "PDF డౌన్‌లోడ్ చేయండి (.pdf)",
      "no.transactions_found": "ఎంచుకున్న ఫిల్టర్‌కు లావాదేవీలు ఏవీ కనుగొనబడలేదు.",

      // Savings
      "savings.title": "పొదుపులు & లక్ష్యాలు",
      "savings.subtitle": "మీ పొదుపు లక్ష్యాలను ట్రాక్ చేసి నిర్వహించండి",
      "total.savings.reserve": "మొత్తం పొదుపు నిల్వ",
      "add.goal": "కస్టమ్ లక్ష్యాన్ని సృష్టించండి",
      "edit.goal": "పొదుపు లక్ష్యాన్ని సవరించండి",
      "deposit": "డిపాజిట్ చేయండి",
      "deposit.amount": "డిపాజిట్ మొత్తం (₹)",
      "confirm.deposit": "డిపాజిట్ నిర్ధారించండి",
      "saved": "సేవ్ చేయబడింది",
      "target": "లక్ష్యం",
      "no.goals": "ఇంకా పొదుపు లక్ష్యాలు సెట్ చేయలేదు. + నొక్కి ప్రారంభించండి!",

      // AI Insights
      "insights.title": "AI ఆర్థిక సలహాదారు",
      "insights.disclaimer": "FIM AI సహాయకుడు బీటాలో ఉన్నాడు. అంతర్దృష్టులు మీ బడ్జెట్ మరియు EMIల నుండి ప్రత్యక్షంగా లెక్కించబడతాయి.",
      "insights.ask_placeholder": "మీ రుణాలు లేదా ఖర్చుల గురించి ఏదైనా అడగండి...",
      "insights.send": "పంపండి",

      // Profile & Settings
      "profile.title": "నా ప్రొఫైల్ & సెట్టింగ్‌లు",
      "profile.subtitle": "మీ ప్రొఫైల్, ఖాతాలు & ప్రాధాన్యతలను నిర్వహించండి",
      "profile.change_photo": "ఫోటో మార్చండి",
      "profile.linked_banks": "లింక్ చేయబడిన బ్యాంక్ ఖాతాలు",
      "profile.add_bank": "బ్యాంకును జోడించండి",
      "profile.no_banks": "ఇంకా ఏ బ్యాంక్ ఖాతాలు లింక్ చేయబడలేదు.",
      "profile.no_banks_sub": "లావాదేవీలను ట్రాక్ చేయడానికి మీ బ్యాంక్ ఖాతాను జోడించండి.",
      "settings.compliance": "సెట్టింగ్‌లు & వర్తింపు",
      "language.preference": "యాప్ భాష",
      "language.preference_sub": "యాప్ భాషను మార్చండి (English, हिन्दी, తెలుగు)",
      "privacy.policy": "గోప్యతా విధానం",
      "privacy.policy_sub": "మా గోప్యతా విధానాన్ని చదవండి",
      "terms.of.use": "వినియోగ నిబంధనలు",
      "terms.of.use_sub": "మా నిబంధనలు మరియు షరతులను చదవండి",
      "emi.reminders": "EMI రిమైండర్ నోటిఫికేషన్‌లు",
      "emi.reminders_enabled": "ప్రారంభించబడింది • రోజువారీ రిమైండర్‌లు సక్రియం",
      "emi.reminders_disabled": "నిలిపివేయబడింది",
      "sign.out": "సైన్ అవుట్",
      "delete.account": "ఖాతాను తొలగించండి",
      "dialog.sign_out_title": "సైన్ అవుట్ చేయండి",
      "dialog.sign_out_msg": "మీరు ఖచ్చితంగా SMART-EMI నుండి సైన్ అవుట్ చేయాలనుకుంటున్నారా?",
      "dialog.delete_account_title": "ఖాతాను తొలగించండి",
      "dialog.delete_account_msg": "మీరు ఖచ్చితంగా తొలగించాలనుకుంటున్నారా? మీ అన్ని రుణాలు, పొదుపులు మరియు ఖర్చుల డేటా శాశ్వతంగా తొలగించబడుతుంది.",
      "cancel": "రద్దు చేయండి",
      "save": "సేవ్ చేయండి",
      "delete": "తొలగించండి",
    }
  };

  static const List<Map<String, dynamic>> _defaultSupportedLanguages = [
    {"code": "en", "name": "English", "nativeName": "English", "isDefault": true, "isActive": true},
    {"code": "hi", "name": "Hindi", "nativeName": "हिन्दी", "isDefault": false, "isActive": true},
    {"code": "te", "name": "Telugu", "nativeName": "తెలుగు", "isDefault": false, "isActive": true},
  ];

  Future<void> init() async {
    _isLoading = true;
    _supportedLanguages = List.from(_defaultSupportedLanguages);
    notifyListeners();

    // 1. Read saved locale
    _currentLanguageCode = await _service.getSavedLanguageCode();

    // 2. Fetch supported languages list
    final apiLangs = await _service.fetchSupportedLanguages();
    if (apiLangs.isNotEmpty) {
      _supportedLanguages = apiLangs;
    }

    // 3. Load English fallback dictionary
    final apiEn = await _service.fetchTranslationDictionary('en');
    _englishFallbackDictionary = {
      ...?_bundledTranslations['en'],
      ...apiEn,
    };

    // 4. Load active language dictionary
    await _loadActiveDictionary(_currentLanguageCode);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadActiveDictionary(String code) async {
    final bundled = _bundledTranslations[code] ?? {};
    final apiDict = await _service.fetchTranslationDictionary(code);
    _activeDictionary = {
      ...bundled,
      ...apiDict,
    };
  }

  /// Instant translation lookup function with multi-level fallback
  String t(String key, {String? defaultText}) {
    if (_activeDictionary.containsKey(key) && _activeDictionary[key]!.isNotEmpty) {
      return _activeDictionary[key]!;
    }
    if (_englishFallbackDictionary.containsKey(key) && _englishFallbackDictionary[key]!.isNotEmpty) {
      return _englishFallbackDictionary[key]!;
    }
    return defaultText ?? key;
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguageCode == languageCode) return;

    _currentLanguageCode = languageCode;
    _isLoading = true;
    notifyListeners();

    // Save locally immediately
    await _service.saveLanguageCodeLocally(languageCode);

    // Fetch active dictionary
    await _loadActiveDictionary(languageCode);

    _isLoading = false;
    notifyListeners();

    // Sync to backend in background if logged in
    _service.syncLanguagePreferenceToBackend(languageCode);
  }
}
