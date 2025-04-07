module Ingredients
  def self.all
    {
      'ru' => {
        # Основные ингредиенты
        'Soba' => 'СОБА',
        'ton' => 'тунец',
        'maguro' => 'тунец',
        'edamame' => 'эдамаме',
        'nori' => 'нори',
        'mango' => 'манго',
        'mango copt' => 'запеченное манго',
        'avocado' => 'авокадо',
        'susan' => 'кунжут',
        'susan alb' => 'белый кунжут',
        'susan negru' => 'черный кунжут',
        'susan alb/negru' => 'белый/черный кунжут',
        'orez' => 'рис',
        'orez fiert' => 'отварной рис',
        'germeni de ceapă' => 'ростки лука',
        'germeni din ceapă' => 'ростки лука',
        'germeni de mazăre' => 'ростки гороха',
        'germeni de secară' => 'ростки ржи',
        'germeni de verdeață' => 'ростки зелени',
        'micro plante' => 'микрозелень',
        'fierți' => 'вареные',
        'Fulgi' => 'ролл',
        'Fulgi de тунец' => 'ролл с тунцом',
        'amestic' => 'амистик',
        'lola' => 'лола',
        'tobiko' => 'тобико',
        'caviar' => 'икра',
        
        
        # Соусы
        'sos ponzu' => 'соус понзу',
        'sos spicy' => 'острый соус',
        'sos thai' => 'тайский соус',
        'sos unagi' => 'соус унаги',
        'sos teriaki' => 'соус терияки',
        'sos tiriyaki' => 'соус терияки',
        'sos de soia' => 'соус соевый',
        'sos de nuci' => 'ореховый соус',
        'sos de roșii' => 'томатный соус',
        'maioneză japoneza' => 'японский майонез',
        'sos spaisy' => 'острый соус',

        # Мясо и рыба
        'Mușchi de vită' => 'говяжья вырезка',
        'carne de vită' => 'говядина',
        'carne de pui' => 'куриное мясо',
        'piept de rață' => 'утиная грудка',
        'carne fiartă de rață' => 'отварная утка',
        'somon' => 'лосось',
        'somon fresh' => 'свежий лосось',
        'somon grill' => 'лосось гриль',
        'somon prăjit' => 'жареный лосось',
        'Țipar' => 'Угорь',
        'anghila' => 'угорь',
        'anghila afumată' => 'копченый угорь',

        # Морепродукты
        'Creveți' => 'Креветки',
        'Creveți fierți' => 'вареные креветки',
        'coctail fructe de mare' => 'коктейль из морепродуктов',
        'cocktail fructe de mare' => 'коктейль из морепродуктов',
        'midii' => 'мидии',
        'crab snow' => 'снежный краб',
        'caviar de somon' => 'икра лосося',
        'icre tobiko' => 'икра тобико',
        'icre de pește zburător' => 'икра летучей рыбы',
        
        # Овощи и грибы
        'ardei california' => 'перец калифорния',
        'ciuperci' => 'грибы',
        'shitake' => 'шитаке',
        'bostănel' => 'цукини',
        'morcov' => 'морковь',
        'castraveți' => 'огурцы',
        'castravete' => 'огурец',
        'roșii chery' => 'помидоры черри',
        'roșii cherry' => 'помидоры черри',
        'salad leaves' => 'листья салата',
        'mix de salată' => 'микс салата',
        'mix de verdeață' => 'микс зелени',
        'busuioc proaspăt' => 'свежий базилик',
        'busuioc verde' => 'зеленый базилик',
        'usturoi' => 'чеснок',
        'chuka' => 'чука',
        'vacame' => 'вакаме',
        'tofu' => 'тофу',

        # Другие ингредиенты
        'philadelphia cream' => 'сливочный сыр филадельфия',
        'cremette' => 'кремет',
        'frișcă' => 'сливки',
        'parmezan' => 'пармезан',
        'panko' => 'панко',
        'ou de găină' => 'куриное яйцо',
        'unt' => 'масло',
        'ulei de masline' => 'оливковое масло',
        'ulei de floarea soarelui' => 'подсолнечное масло',
        'vin sec alb' => 'белое сухое вино',
        'vasabi' => 'васаби',
        'ghimbir' => 'имбирь',
        'ghimbir marinat' => 'маринованный имбирь',
        'fidea' => 'лапша',
        'bulion ramen' => 'бульон рамен',
        'bulion tom yum' => 'бульон том ям',
        'bulion miso' => 'бульон мисо',

        # Супы и их ингредиенты
        'tăiței' => 'лапша',
        'tăiței ramen' => 'лапша рамен',
        'tăiței udon' => 'лапша удон',
        'tăiței soba' => 'лапша соба',
        'ou fiert' => 'вареное яйцо',
        'ceapă verde' => 'зеленый лук',
        'alge wakame' => 'водоросли вакаме',
        'porumb' => 'кукуруза',
        'lapte de cocos' => 'кокосовое молоко',
        'pastă tom yum' => 'паста том ям',
        'pastă miso' => 'паста мисо',
        'ciuperci champinion' => 'грибы шампиньоны',
        'ciuperci enoki' => 'грибы эноки',
        'fasole roșie' => 'красная фасоль',
        'fasole verde' => 'зеленая фасоль',
        'porumb dulce' => 'сладкая кукуруза',
        'ardei iute' => 'острый перец',
        'frunze de coriandru' => 'листья кориандра',
        'mentă' => 'мята',
        'lime' => 'лайм',
      },
      'en' => {
        # Базовые ингредиенты суши
        'ton' => 'tuna',
        'edamame' => 'edamame',
        'nori' => 'nori',
        'mango' => 'mango',
        'mango copt' => 'baked mango',
        'avocado' => 'avocado',
        'susan' => 'sesame',
        'susan alb' => 'white sesame',
        'susan negru' => 'black sesame',
        'susan alb/negru' => 'white/black sesame',
        'orez' => 'rice',
        'orez fiert' => 'boiled rice',
        'germeni de ceapă' => 'onion sprouts',
        'germeni din ceapă' => 'onion sprouts',
        'germeni de mazăre' => 'pea sprouts',
        'germeni de secară' => 'rye sprouts',
        'germeni de verdeață' => 'green sprouts',
        'micro plante' => 'microgreens',
        'fierți' => 'boiled',
        'Fulgi' => 'roll',
        'Fulgi de тунец' => 'tuna roll',
        'amestic' => 'amestic',
        'lola' => 'lola',
        'tobiko' => 'tobiko',
        'caviar' => 'caviar',
        'de' => 'with',

        # Соусы
        'sos ponzu' => 'ponzu sauce',
        'sos spicy' => 'spicy sauce',
        'sos thai' => 'thai sauce',
        'sos unagi' => 'unagi sauce',
        'sos teriaki' => 'teriyaki sauce',
        'sos tiriyaki' => 'teriyaki sauce',
        'sos de soia' => 'soy sauce',
        'sos de nuci' => 'nut sauce',
        'sos de roșii' => 'tomato sauce',
        'maioneză japoneza' => 'japanese mayonnaise',
        'sos spaisy' => 'spicy sauce',

        # Мясо и рыба
        'Mușchi de vită' => 'beef tenderloin',
        'carne de vită' => 'beef',
        'carne de pui' => 'chicken',
        'piept de rață' => 'duck breast',
        'carne fiartă de rață' => 'boiled duck',
        'somon' => 'salmon',
        'somon fresh' => 'fresh salmon',
        'somon grill' => 'grilled salmon',
        'somon prăjit' => 'fried salmon',
        'Țipar' => 'Eel',
        'anghila' => 'eel',
        'anghila afumată' => 'smoked eel',

        # Морепродукты
        'Creveți' => 'Shrimp',
        'Creveți fierți' => 'boiled shrimp',
        'coctail fructe de mare' => 'seafood cocktail',
        'cocktail fructe de mare' => 'seafood cocktail',
        'midii' => 'mussels',
        'crab snow' => 'snow crab',
        'caviar de somon' => 'salmon caviar',
        'icre tobiko' => 'tobiko caviar',
        'icre de pește zburător' => 'flying fish roe',

        # Овощи и грибы
        'ardei california' => 'bell pepper',
        'ciuperci' => 'mushrooms',
        'shitake' => 'shiitake',
        'bostănel' => 'zucchini',
        'morcov' => 'carrot',
        'castraveți' => 'cucumbers',
        'castravete' => 'cucumber',
        'roșii chery' => 'cherry tomatoes',
        'roșii cherry' => 'cherry tomatoes',
        'salad leaves' => 'salad leaves',
        'mix de salată' => 'salad mix',
        'mix de verdeață' => 'green mix',
        'busuioc proaspăt' => 'fresh basil',
        'busuioc verde' => 'green basil',
        'usturoi' => 'garlic',
        'chuka' => 'chuka',
        'vacame' => 'wakame',
        'tofu' => 'tofu',

        # Другие ингредиенты
        'philadelphia cream' => 'cream cheese philadelphia',
        'cremette' => 'cremette',
        'frișcă' => 'cream',
        'parmezan' => 'parmesan',
        'panko' => 'panko',
        'ou de găină' => 'chicken egg',
        'unt' => 'butter',
        'ulei de masline' => 'olive oil',
        'ulei de floarea soarelui' => 'sunflower oil',
        'vin sec alb' => 'white dry wine',
        'vasabi' => 'wasabi',
        'ghimbir' => 'ginger',
        'ghimbir marinat' => 'pickled ginger',
        'fidea' => 'noodles',
        'bulion ramen' => 'ramen broth',
        'bulion tom yum' => 'tom yum broth',
        'bulion miso' => 'miso broth',

        # Супы и их ингредиенты
        'bulion' => 'broth',
        'tăiței' => 'noodles',
        'tăiței ramen' => 'ramen noodles',
        'tăiței udon' => 'udon noodles',
        'tăiței soba' => 'soba noodles',
        'ou fiert' => 'boiled egg',
        'ceapă verde' => 'green onion',
        'alge wakame' => 'wakame seaweed',
        'porumb' => 'corn',
        'lapte de cocos' => 'coconut milk',
        'pastă tom yum' => 'tom yum paste',
        'pastă miso' => 'miso paste',
        'ciuperci champinion' => 'champignon mushrooms',
        'ciuperci enoki' => 'enoki mushrooms',
        'fasole roșie' => 'red beans',
        'fasole verde' => 'green beans',
        'porumb dulce' => 'sweet corn',
        'ardei iute' => 'chili pepper',
        'frunze de coriandru' => 'coriander leaves',
        'mentă' => 'mint',
        'lime' => 'lime',
      }
    }
  end

  def self.units(count, language)
    case language
    when 'ru'
      "#{count} шт."
    when 'ro'
      "#{count} buc."
    when 'en'
      "#{count} pcs."
    end
  end

  def self.grams(count, language)
    case language
    when 'ru'
      "#{count}г"
    when 'ro'
      "#{count}g"
    when 'en'
      "#{count}g"
    end
  end

  def self.milliliters(count, language)
    case language
    when 'ru'
      "#{count}мл"
    when 'ro'
      "#{count}ml"
    when 'en'
      "#{count}ml"
    end
  end

  def self.price_format(price, language)
    case language
    when 'ru'
      "Цена - #{price} лей"
    when 'ro'
      "PREȚ - #{price} lei"
    when 'en'
      "PRICE - #{price} MDL"
    end
  end
end