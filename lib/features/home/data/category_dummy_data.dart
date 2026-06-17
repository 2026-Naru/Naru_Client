import '../domain/category_model.dart';

const List<CategoryModel> categoryDummyData = [
  CategoryModel(
    id: 'korean',
    title: 'Korean',
    image: 'assets/images/cat_korean.png',
    description:
        'Warm rice bowls, stews, and bold Korean favorites ready for delivery.',
    items: [
      CategoryItemModel(
        name: 'Yupki Ddukbokki Sillim',
        image: 'assets/images/food_tteokbokki.png',
        description: 'Spicy tteokbokki with chewy rice cakes and fish cake.',
      ),
      CategoryItemModel(
        name: 'Simin Jokbal & Bossam',
        image: 'assets/images/food_jokbal.png',
        description: 'Tender jokbal and bossam plates for a filling meal.',
      ),
      CategoryItemModel(
        name: 'Seobu Cheonggukjang',
        image: 'assets/images/SeobuCheongg_profile.png',
        description: 'Comforting Korean stew with deep savory flavor.',
      ),
    ],
  ),
  CategoryModel(
    id: 'chicken',
    title: 'Chicken',
    image: 'assets/images/cat_chicken_single.png',
    description:
        'Crispy fried chicken, sweet-spicy sauces, and franchise favorites.',
    items: [
      CategoryItemModel(
        name: 'Nene Chicken',
        image: 'assets/images/franchise_nene_bg.png',
        description: 'Crispy chicken with classic Korean dipping sauces.',
      ),
      CategoryItemModel(
        name: 'BHC Chicken',
        image: 'assets/images/cat_bhc.png',
        description: 'Popular chicken sets with shareable portions.',
      ),
      CategoryItemModel(
        name: 'BBQ Chicken',
        image: 'assets/images/cat_bbq.png',
        description: 'Golden olive chicken and bold seasoned menus.',
      ),
    ],
  ),
  CategoryModel(
    id: 'street',
    title: 'Street',
    image: 'assets/images/cat_street.png',
    description:
        'Street-food classics for quick cravings, late snacks, and sharing.',
    items: [
      CategoryItemModel(
        name: 'Mala Tteokbokki',
        image: 'assets/images/Mala_Tteokbokki.png',
        description: 'A spicy mala twist on chewy Korean tteokbokki.',
      ),
      CategoryItemModel(
        name: 'Rosé Tteokbokki',
        image: 'assets/images/Mala_Tteokbokki.png',
        description: 'Creamy rosé sauce with rice cakes and sausage.',
      ),
      CategoryItemModel(
        name: 'Yupki Set Menu',
        image: 'assets/images/YeopgiMenu.png',
        description: 'A dependable spicy set for two or more.',
      ),
    ],
  ),
  CategoryModel(
    id: 'bbq',
    title: 'BBQ',
    image: 'assets/images/cat_chicken.png',
    description: 'Grilled, smoky, and saucy picks for a hearty delivery night.',
    items: [
      CategoryItemModel(
        name: 'Texas BBQ Ghost Black',
        image: 'assets/images/hepaticboneinjury.png',
        description: 'Smoky barbecue flavor with a punchy sauce finish.',
      ),
      CategoryItemModel(
        name: 'Spicy Marinated BBQ',
        image: 'assets/images/Spicy-MarinatedSa.png',
        description: 'Sweet-spicy marinated meat grilled for deep flavor.',
      ),
      CategoryItemModel(
        name: 'Spicy Seasoned Plate',
        image: 'assets/images/Spicyseasoned.png',
        description: 'A richly seasoned plate made for sharing.',
      ),
    ],
  ),
  CategoryModel(
    id: 'asian',
    title: 'Asian',
    image: 'assets/images/cat_asian.png',
    description:
        'Bright, savory Asian dishes from noodles to rice-friendly plates.',
    items: [
      CategoryItemModel(
        name: 'Yookhoe Barun',
        image: 'assets/images/Yookhoe Barun_profile.png',
        description: 'Fresh Korean-style beef tartare and sides.',
      ),
      CategoryItemModel(
        name: 'White Seafood Pizza',
        image: 'assets/images/WhiteSeafoodPizza.png',
        description: 'Seafood-topped comfort menu with a creamy base.',
      ),
      CategoryItemModel(
        name: 'Jangchungdong Plate',
        image: 'assets/images/Jangchungdong.png',
        description: 'A savory classic with generous portions.',
      ),
    ],
  ),
  CategoryModel(
    id: 'desserts',
    title: 'Desserts',
    image: 'assets/images/cat_desserts.png',
    description: 'Sweet treats, drinks, and bakery picks to finish the meal.',
    items: [
      CategoryItemModel(
        name: 'Cafe Bombom Sillim',
        image: 'assets/images/food_cafe.png',
        description: 'Sweet drinks, coffee, and refreshing dessert cups.',
      ),
      CategoryItemModel(
        name: 'Bback Dabang',
        image: 'assets/images/bdb.svg',
        description: 'Cafe drinks and easy desserts near you.',
      ),
      CategoryItemModel(
        name: 'Bongus Rice Burger',
        image: 'assets/images/cat_bongus.png',
        description: 'A simple sweet-and-savory snack stop.',
      ),
    ],
  ),
  CategoryModel(
    id: 'coffee',
    title: 'Coffee',
    image: 'assets/images/cat_coffee.png',
    description:
        'Coffee, tea, and cafe drinks for mornings and afternoon breaks.',
    items: [
      CategoryItemModel(
        name: 'Ediya Coffee Sillim',
        image: 'assets/images/cat_ediya.png',
        description: 'Reliable iced coffee and quick cafe delivery.',
      ),
      CategoryItemModel(
        name: 'Cafe Bombom',
        image: 'assets/images/cat_bombom.png',
        description: 'Fruit drinks, lattes, and sweet cafe favorites.',
      ),
      CategoryItemModel(
        name: 'Bback Dabang',
        image: 'assets/images/bdb.svg',
        description: 'Large coffees and dessert drinks at friendly prices.',
      ),
    ],
  ),
  CategoryModel(
    id: 'fast-food',
    title: 'Fast Food',
    image: 'assets/images/cat_fastfood.png',
    description: 'Burgers, fries, pizza, and quick meals when speed matters.',
    items: [
      CategoryItemModel(
        name: 'Lotteria',
        image: 'assets/images/franchise_lotteria_bg.png',
        description: 'Burgers, fries, and familiar fast-food sets.',
      ),
      CategoryItemModel(
        name: 'Domino Pizza',
        image: 'assets/images/franchise_domino_bg.png',
        description: 'Pizza combos for fast dinner plans.',
      ),
      CategoryItemModel(
        name: 'White Seafood Pizza',
        image: 'assets/images/WhiteSeafoodPizza.png',
        description: 'Creamy seafood pizza with a crisp edge.',
      ),
    ],
  ),
  CategoryModel(
    id: 'healthy',
    title: 'Healthy',
    image: 'assets/images/cat_healthy.png',
    description:
        'Lighter bowls, balanced meals, and fresh picks for easy eating.',
    items: [
      CategoryItemModel(
        name: 'Fresh Bibim Bowl',
        image: 'assets/images/cat_healthy.png',
        description: 'A balanced bowl with greens, rice, and savory sauce.',
      ),
      CategoryItemModel(
        name: 'Seafood Light Plate',
        image: 'assets/images/WhiteSeafoodPizza.png',
        description: 'A lighter seafood option with clean flavors.',
      ),
      CategoryItemModel(
        name: 'Yookhoe Barun Set',
        image: 'assets/images/Yookhoe Barun_profile.png',
        description: 'Fresh protein and sides for a satisfying meal.',
      ),
    ],
  ),
  CategoryModel(
    id: 'late-night',
    title: 'Late Night',
    image: 'assets/images/cat_late_night.png',
    description: 'Big flavors and filling menus for late cravings after dark.',
    items: [
      CategoryItemModel(
        name: 'Late Night Tteokbokki',
        image: 'assets/images/food_tteokbokki.png',
        description: 'Spicy comfort food that works best at night.',
      ),
      CategoryItemModel(
        name: 'Jokbal Night Set',
        image: 'assets/images/Jokbal_Mix.png',
        description: 'A generous late-night jokbal mix for sharing.',
      ),
      CategoryItemModel(
        name: 'Spicy Seasoned Chicken',
        image: 'assets/images/Spicyseasoned.png',
        description: 'Saucy, spicy, and built for midnight cravings.',
      ),
    ],
  ),
];
