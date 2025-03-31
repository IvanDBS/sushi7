--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Homebrew)
-- Dumped by pg_dump version 14.17 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying,
    url_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id bigint NOT NULL,
    order_id bigint,
    product_id bigint,
    quantity integer,
    price numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    user_id bigint,
    status character varying,
    phone character varying,
    address character varying,
    comment text,
    payment_method character varying,
    checkout_step character varying,
    payment_id character varying,
    payment_status character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    name character varying,
    description text,
    price numeric(10,2),
    image_url character varying,
    category_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    telegram_id integer,
    first_name character varying,
    last_name character varying,
    username character varying,
    language character varying DEFAULT 'ru'::character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2025-03-31 18:48:26.620955	2025-03-31 18:48:26.620959
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, url_name, created_at, updated_at) FROM stdin;
1	🍱 Сеты	seturi	2025-03-29 17:16:47.560131	2025-03-29 17:16:47.560131
2	🍣 Суши	sushi	2025-03-29 17:16:47.56254	2025-03-29 17:16:47.56254
3	🍙 Маки-Нигири-Гункан	maki-nigiri-guncan	2025-03-29 17:16:47.563649	2025-03-29 17:16:47.563649
4	🥗 Поке Боул	poke-bowl	2025-03-29 17:16:47.564915	2025-03-29 17:16:47.564915
5	🍤 Темпура	tempura	2025-03-29 17:16:47.56596	2025-03-29 17:16:47.56596
6	🌋 Вулкан	vulcan	2025-03-29 17:16:47.567128	2025-03-29 17:16:47.567128
7	🥢 Вок	wok	2025-03-29 17:16:47.567887	2025-03-29 17:16:47.567887
8	🥣 Супы	supe	2025-03-29 17:16:47.568329	2025-03-29 17:16:47.568329
9	🥤 Напитки	bauturi	2025-03-29 17:16:47.568653	2025-03-29 17:16:47.568653
10	🍰 Десерты	dessert-2	2025-03-29 17:16:47.568957	2025-03-29 17:16:47.568957
11	🏷️ Акции	reduceri	2025-03-29 17:16:47.569262	2025-03-29 17:16:47.569262
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, quantity, price, created_at, updated_at) FROM stdin;
1	1	85	1	85	2025-03-29 17:21:46.652893	2025-03-29 17:21:46.654051
2	2	64	1	195	2025-03-29 17:28:47.262391	2025-03-29 17:28:47.263773
3	3	82	1	20	2025-03-29 17:30:40.837457	2025-03-29 17:30:40.839007
4	4	64	1	195	2025-03-29 17:36:34.329067	2025-03-29 17:36:34.330595
5	5	64	1	195	2025-03-29 17:37:54.695891	2025-03-29 17:37:54.696993
6	5	51	1	165	2025-03-29 17:38:11.409103	2025-03-29 17:38:11.409744
7	6	82	1	20	2025-03-29 17:45:38.109009	2025-03-29 17:45:38.110475
8	7	82	1	20	2025-03-29 17:48:44.286448	2025-03-29 17:48:44.287806
9	8	63	1	160	2025-03-29 17:52:16.087683	2025-03-29 17:52:16.088566
10	9	65	1	200	2025-03-31 12:16:31.537024	2025-03-31 12:16:31.541042
11	10	7	2	1850.0	2025-03-31 18:53:59.067923	2025-03-31 18:54:01.913603
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, user_id, status, phone, address, comment, payment_method, checkout_step, payment_id, payment_status, created_at, updated_at) FROM stdin;
1	1	paid	0567567567	yjtyjtyjytj	4tjtyjyjtyj	card	payment	test_payment_1743268920	success	2025-03-29 17:21:45.361427	2025-03-29 17:27:42.519672
2	1	paid	034534534534	укпукпукпукп	пукпукп	card	payment	test_payment_1743269343	success	2025-03-29 17:28:45.703686	2025-03-29 17:33:59.5357
3	1	cancelled	9079079090	еоероерое	еое	card	payment	test_payment_1743269452	pending	2025-03-29 17:30:35.453021	2025-03-29 17:30:52.761306
4	1	cancelled	0980890890	лодолд	олд	card	payment	test_payment_1743269806	pending	2025-03-29 17:36:32.95941	2025-03-29 17:36:46.769953
5	1	paid	0567567567	апрапра пр апр	пр	card	payment	test_payment_1743269910	success	2025-03-29 17:37:52.659439	2025-03-29 17:42:30.60817
6	1	paid	0356456456	4кепркерр	крррр	card	payment	test_payment_1743270353	success	2025-03-29 17:45:36.966502	2025-03-29 17:46:03.607399
7	1	accepted	0667867867	ПРОПРОПРО	ПРОПРОПРО	card	payment	test_payment_1743270532	success	2025-03-29 17:48:43.311443	2025-03-29 17:49:04.489891
8	1	accepted	0789789789	пппппп	п	cash	payment	\N	\N	2025-03-29 17:52:11.860213	2025-03-29 17:52:40.508272
9	1	cancelled	0567567567	yjytjt yjty	y	card	payment	\N	\N	2025-03-29 17:52:29.901143	2025-03-31 12:16:49.199116
11	1	cart	\N	\N	\N	\N	\N	\N	\N	2025-03-31 18:54:16.286443	2025-03-31 18:54:16.286443
10	1	accepted	-04353454353	345345345	rgerg	cash	comment	\N	\N	2025-03-31 18:53:51.542871	2025-03-31 18:54:20.366014
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, price, image_url, category_id, created_at, updated_at) FROM stdin;
1	Big party pack set	CANADA, IMPERIAL ROLL, PHILADELPHIA EBI, CALIFORNIA BLACK&WHITE, UNAGI TEMPURA, KANI HOT VULCN, SAKE MAKI, KAPPA MAKI -1.700/150/75/60g 64buc CANADA, IMPERIAL ROLL, PHILADELPHIA EBI, CALIFORNIA BLACK&WHITE, UNAGI TEMPURA, KANI HOT VULCN, SAKE MAKI, KAPPA MAKI -1.700/150/75/60g 64 шт.	1000.00	https://ohmysushi.md/wp-content/uploads/2024/09/d2b47005ce2edbe8d970381be7dccab1420b339be51994d7006c4ecb144c8955-247x247.jpg	1	2025-03-29 17:16:50.539405	2025-03-29 17:16:50.539405
2	California set	California classic, california kani white, california sake, california black & white. 32 buc. California classic, california kani white, california sake, california black & white. 32 шт.	580.00	https://ohmysushi.md/wp-content/uploads/2024/09/9b6b8fffe6caea9bc17898cdbdc33172674c695862d4a28eded6bef463f41e73-247x247.jpg	1	2025-03-29 17:16:52.162157	2025-03-29 17:16:52.162157
3	Dragon set	Golden dragon, red dragon, green dragon, sake dragon – 1.200/120/75/75g 32 buc. Golden dragon, red dragon, green dragon, sake dragon – 1.200/120/75/75g 32 шт.	750.00	https://ohmysushi.md/wp-content/uploads/2024/09/9d40c7873fb32e2f13ff8919824fb7484da561cab7dba2219fc645756c1c6994-247x247.jpg	1	2025-03-29 17:16:53.798878	2025-03-29 17:16:53.798878
4	Events set	PHILADELPHIA,CALIFORNIA BLACK & WHITE, Imperator, KANI TEMPURA, KANI HOT VULKAN,SAKE MAKI – 1.600/150/75/60g 48 buc. PHILADELPHIA,CALIFORNIA BLACK & WHITE, Imperator, KANI TEMPURA, KANI HOT VULKAN,SAKE MAKI – 1.600/150/75/60g 48 шт.	800.00	https://ohmysushi.md/wp-content/uploads/2024/09/b20c45e9262cfe8d508c5aef48801ac044288d3ede5e3a58ec474a8d88a6f0c4-247x247.jpg	1	2025-03-29 17:16:55.443604	2025-03-29 17:16:55.443604
5	Maki set	Maguro maki, kappa maki, ebi maki, sake maki, avocado maki – 700/100/50/30g 40 buc. Maguro maki, kappa maki, ebi maki, sake maki, avocado maki – 700/100/50/30g 40 шт.	300.00	https://ohmysushi.md/wp-content/uploads/2024/09/7964e13e78b258174357c8cb50468baa2c3bb8ff8fbb767952e865ce417363ab-247x247.jpg	1	2025-03-29 17:16:57.080509	2025-03-29 17:16:57.080509
6	Oh ! My sushi set	Sake tempura, maguro tempura, kani tempura, california classic, canada, green dragon, brunt sake, hadaka sake, hadaka maguro, kappa maki, avocado maki, maguro maki, nigiri sake, nigiri ebi, nigiri maguro, chuka salad – 3250/250/150/100g 91buc Sake tempura, maguro tempura, kani tempura, california classic, canada, green dragon, brunt sake, hadaka sake, hadaka maguro, kappa maki, avocado maki, maguro maki, nigiri sake, nigiri ebi, nigiri maguro, chuka salad – 3250/250/150/100g 91buc	1500.00	https://ohmysushi.md/wp-content/uploads/2024/09/30553b43fa0f61cc11996dbabd0f8239ad845d85061d9d94047bfbc9a8131b47-247x247.jpg	1	2025-03-29 17:16:58.821507	2025-03-29 17:16:58.821507
7	Oh my super sushi set	Golden dragon, sake dragon, green dragon, maguro dragon, alaska, Philadelphia duble cheese, maguro roll, hadaka sake, hadaka ebi, avocado maki, sake maki, kappa maki, maguro maki, ebi maki, tobiko cheese maki – 3.500/300/200/150g 120buc Golden dragon, sake dragon, green dragon, maguro dragon, alaska, Philadelphia duble cheese, maguro roll, hadaka sake, hadaka ebi, avocado maki, sake maki, kappa maki, maguro maki, ebi maki, tobiko cheese maki – 3.500/300/200/150g 120buc	1850.00	https://ohmysushi.md/wp-content/uploads/2024/09/d4eccd-247x247.jpg	1	2025-03-29 17:17:00.458114	2025-03-29 17:17:00.458114
8	OTOMO SUSHI SET	OTOMO SUSHI SET	290.00	https://ohmysushi.md/wp-content/uploads/2024/12/img_8129-247x247.jpeg	1	2025-03-29 17:17:02.102537	2025-03-29 17:17:02.102537
9	Party set	PHILADELPHIA,CALIFORNIA,CALIFORNIA BLACK &amp; WHITE, EBI TEMPURA ,SAKE MAKI – 1.270/90/45/30g 40 buc. PHILADELPHIA,CALIFORNIA,CALIFORNIA BLACK &amp; WHITE, EBI TEMPURA ,SAKE MAKI – 1.270/90/45/30g 40 шт.	700.00	https://ohmysushi.md/wp-content/uploads/2024/09/04265a740e461a3601150e708471198e36b8b1407e0a3b38b085469acbb084de-247x247.jpg	1	2025-03-29 17:17:03.740374	2025-03-29 17:17:03.740374
10	Philadelphia set	Philadelphia, philadelphia de lux, philadelphia ebi – 870/60/30/30g 24buc Philadelphia, philadelphia de lux, philadelphia ebi – 870/60/30/30g 24 шт.	500.00	https://ohmysushi.md/wp-content/uploads/2024/09/70dd6e9dfab69fffb28748d2f42b0a3fe2877acf6f13cdb21f589be4b52d941e-247x247.jpg	1	2025-03-29 17:17:05.372178	2025-03-29 17:17:05.372178
11	Set aiko	Philadelphia, california kani white, teriyaki maki – 700/100/30/15g 24 buc Philadelphia, california kani white, teriyaki maki – 700/100/30/15g 24 шт.	360.00	https://ohmysushi.md/wp-content/uploads/2024/09/1a26e9c1507ba81d965bc854c1d8b9d08830ebf2ff5090b867f8b389c18d8f4d-247x247.jpg	1	2025-03-29 17:17:07.014572	2025-03-29 17:17:07.014572
12	Set art	Canada, california classic, nigiri sake, nigiri maguro, nigiri ebi, hadaka sake, hadaka maguro, kappa maki, avocado maki, maguro maki ,chuka salad – 1800/150/100/60g 59 buc. Canada, california classic, nigiri sake, nigiri maguro, nigiri ebi, hadaka sake, hadaka maguro, kappa maki, avocado maki, maguro maki ,chuka salad – 1800/150/100/60g 59 шт.	900.00	https://ohmysushi.md/wp-content/uploads/2024/09/f79df468b57248088afa735226efc49434d5b63153c06b8bcd470e3cbbf80fa5-247x247.jpg	1	2025-03-29 17:17:08.651537	2025-03-29 17:17:08.651537
13	Bonito ebi	Fulgi de ton, avocado, tobiko, philadelphia cream, creveți – 280/50/25/15 g. Fulgi de ton, avocado, tobiko, philadelphia cream, creveți – 280/50/25/15 g.	185.00	https://ohmysushi.md/wp-content/uploads/2024/09/9b2e3ea8b1829e30ad0a90fe0dc1f4e748e61663cb3961a657b0ca4e3e66926d-247x247.jpg	2	2025-03-29 17:17:12.44036	2025-03-29 17:17:12.44036
14	Bonito sake	Fulgi de ton, philadelphia cream, castraveți, somon, tobiko – 280/50/25/15 g. Fulgi de ton, philadelphia cream, castraveți, somon, tobiko – 280/50/25/15 g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/bf6e444b8fcfcdf358b7d872ecd533519e3f25a7e501ce202224cf17df5ae109-247x247.jpg	2	2025-03-29 17:17:14.078192	2025-03-29 17:17:14.078192
15	Burn cheese	Cedar, philadelphia cream, castraveți, somon prăjit, sos spicy, gemeni de verdeață – 300/50/25/15 g. Cedar, philadelphia cream, castraveți, somon prăjit, sos spicy, gemeni de verdeață – 300/50/25/15 g.	175.00	https://ohmysushi.md/wp-content/uploads/2024/09/3142e79214506c5431ba34792031acb3d2aea392349b22413dbc0b6b07f58804-247x247.jpg	2	2025-03-29 17:17:15.713693	2025-03-29 17:17:15.713693
16	Burn sake	Somon grill, philadelphia cream, castraveți, avocado, crevete, sos spicy, gemeni de verdeață – 300/50/25/15 g. Somon grill, philadelphia cream, castraveți, avocado, crevete, sos spicy, gemeni de verdeață – 300/50/25/15 g.	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/329df6e196819c96cf2f22b0172405eac21147c8fb735bdd5d872e4b77d57706-247x247.jpg	2	2025-03-29 17:17:17.458595	2025-03-29 17:17:17.458595
17	California classic	Tobico, creveți, avocado, maioneză japoneza – 280/50/25/15 g. Tobico, creveți, avocado, maioneză japoneza – 280/50/25/15 g.	190.00	https://ohmysushi.md/wp-content/uploads/2024/09/2c9ea4cdce00013b5af6c9e816cd6a108856ded12fba8f809b2e09373811563d-247x247.jpg	2	2025-03-29 17:17:19.19568	2025-03-29 17:17:19.19568
18	California kani white	Crab snow, susan alb, castraveți, avocado, cremette – 280/50/25/15 g. Crab snow, susan alb, castraveți, avocado, cremette – 280/50/25/15 g.	165.00	https://ohmysushi.md/wp-content/uploads/2024/09/d59383dd1a7362846702cb6d2e5c361d2c91c7c92e4d42124016e3af53ffb57e-247x247.jpg	2	2025-03-29 17:17:20.912241	2025-03-29 17:17:20.912241
19	California maguro black	Tobico, ton, castraveți, avocado, cremette. – 280/50/25/15 g. Tobico, ton, castraveți, avocado, cremette. – 280/50/25/15 g.	190.00	https://ohmysushi.md/wp-content/uploads/2024/09/77a05af1f23956b5603b76091bebdbf088a0761da09f9768a14b0802efa906ee-247x247.jpg	2	2025-03-29 17:17:22.500307	2025-03-29 17:17:22.500307
20	California sake	Tobiko, castraveți, avocado, somon, cremette – 280/50/25/15 g. Tobiko, castraveți, avocado, somon, cremette – 280/50/25/15 g.	175.00	https://ohmysushi.md/wp-content/uploads/2024/09/32534ab595cb6d59b0e5a0b1bd4043175b9142db9d56c81e5c99807db9fa3dd0-247x247.jpg	2	2025-03-29 17:17:24.11408	2025-03-29 17:17:24.11408
21	California unagi	Susan, țipar, avocado, castraveți, philadelphia cream, sos unagi – 280/50/25/15g. Susan, țipar, avocado, castraveți, philadelphia cream, sos unagi – 280/50/25/15g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/11c73cb59448c6d844f8abfb1ea32720195b1ba9f3956db37d55c4f11046067e-247x247.jpg	2	2025-03-29 17:17:25.857254	2025-03-29 17:17:25.857254
22	Canada	Țipar, avocado, somon, philadelphia cream, susan, sos unagi – 280/50/25/15 g. Țipar, avocado, somon, philadelphia cream, susan, sos unagi – 280/50/25/15 g.	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/3a776c82f6924d231e8af9a9ec9933b1399b5478434c6e440cc5c697b3c902d2-247x247.jpg	2	2025-03-29 17:17:27.492228	2025-03-29 17:17:27.492228
23	Chuka ebi	Chuka, creveți, avocado, philadelphia cream, susan – 300/50/25/15 g. Chuka, creveți, avocado, philadelphia cream, susan – 300/50/25/15 g.	185.00	https://ohmysushi.md/wp-content/uploads/2024/09/32da301d1b375644f7c8497bc2c99c27e2fb42d5b41c03532f1f201d64c089a3-247x247.jpg	2	2025-03-29 17:17:29.088969	2025-03-29 17:17:29.088969
24	Chuka sake	Chuka, somon, castraveți, mango, susan, philadelphia cream – 300/50/25/15 g. Chuka, somon, castraveți, mango, susan, philadelphia cream – 300/50/25/15 g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/5e0b6c5d4c6a4e88ec51aa5b0a405b283d856f529d602565d81513e8e6bcb4a9-247x247.jpg	2	2025-03-29 17:17:30.765046	2025-03-29 17:17:30.765046
25	Avocado Maki	Avocado, orez, nori, susan, vasabi, ghimbir, sos de soia – 140/50/25/15g Avocado, orez, nori, susan, vasabi, ghimbir, sos de soia – 140/50/25/15g	65.00	https://ohmysushi.md/wp-content/uploads/2024/09/Avocado-Maki-247x247.jpeg	3	2025-03-29 17:17:34.560842	2025-03-29 17:17:34.560842
26	Chuka Maki	Chuka, orez, nori, susan, sos de nuci, vasabi, ghimbir, sos soia – 140/50/25/15g Chuka, orez, nori, susan, sos de nuci, vasabi, ghimbir, sos soia – 140/50/25/15g	67.00	https://ohmysushi.md/wp-content/uploads/2024/09/Chuka-Maki-247x247.jpeg	3	2025-03-29 17:17:36.195232	2025-03-29 17:17:36.195232
27	Ebi Mak	Creveți, susan, orez, nori, vasabi, ghimbir, sos de soia – 140/50/25/15 g. Creveți, susan, orez, nori, vasabi, ghimbir, sos de soia – 140/50/25/15 g.	80.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ebi-Mak-247x247.jpeg	3	2025-03-29 17:17:37.785665	2025-03-29 17:17:37.785665
28	Gnkan Unagi	Orez, nori, anghila, sos spicy, unagi – 1/60g Orez, nori, anghila, sos spicy, unagi – 1/60g	65.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gnkan-Unagi-247x247.jpeg	3	2025-03-29 17:17:39.475433	2025-03-29 17:17:39.475433
29	Gunkan EBI	Orez, nori, creveți, sos spicy – 1/60g Orez, nori, creveți, sos spicy – 1/60g	55.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-EBI-247x247.jpeg	3	2025-03-29 17:17:41.114358	2025-03-29 17:17:41.114358
30	Gunkan Maguro	Orez, nori, ton, sos spicy – 1/60 g Orez, nori, ton, sos spicy – 1/60 g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-Maguro-247x247.jpeg	3	2025-03-29 17:17:42.749417	2025-03-29 17:17:42.749417
31	Gunkan Sake	Orez, nori, somon, sos spicy -1/60g Orez, nori, somon, sos spicy -1/60g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-Sake-247x247.jpeg	3	2025-03-29 17:17:44.368067	2025-03-29 17:17:44.368067
32	Gunkan Tobico	Orez, nori, icre de pește zburător – 1/60g Orez, nori, icre de pește zburător – 1/60g	75.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-Tobico-247x247.jpeg	3	2025-03-29 17:17:45.974742	2025-03-29 17:17:45.974742
33	Gunkn Caviar	Orez, nori, caviar de somon – 1/60g Orez, nori, caviar de somon – 1/60g	90.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkn-Caviar-247x247.jpeg	3	2025-03-29 17:17:47.663052	2025-03-29 17:17:47.663052
34	Kani Maki	Crab snow, susan, nori, unagi, vasabi, ghimbir, sos soia.)- 140/50/25/15 g. Crab snow, susan, nori, unagi, vasabi, ghimbir, sos soia.)- 140/50/25/15 g.	65.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kani-Maki-247x247.jpeg	3	2025-03-29 17:17:49.306304	2025-03-29 17:17:49.306304
35	Kappa Maki	Castraveți, orez, susan, nori, vasabi, ghimbir, sos soia – 140/50/25/15g Castraveți, orez, susan, nori, vasabi, ghimbir, sos soia – 140/50/25/15g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kappa-Maki-247x247.jpeg	3	2025-03-29 17:17:50.945228	2025-03-29 17:17:50.945228
36	Nigiri BURNT	Orez cu somon grill – 1/35g Orez cu somon grill – 1/35g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Nigiri-BURNT-247x247.jpeg	3	2025-03-29 17:17:52.583729	2025-03-29 17:17:52.583729
37	Poke Ebi	Creveți fierți, edamame, mango copt, roșii chery, avocado, icre tobiko, orez fiert, sos ponzu, sos spicy, germeni din ceapă – 400g Creveți fierți, edamame, mango copt, roșii chery, avocado, icre tobiko, orez fiert, sos ponzu, sos spicy, germeni din ceapă – 400g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Ebi-247x247.jpeg	4	2025-03-29 17:17:56.181157	2025-03-29 17:17:56.181157
38	Poke Maguro	Ton, edamame, nori, mango copt, avocado, susan, orez fiert, germeni de ceapă, sos ponzu – 400g Ton, edamame, nori, mango copt, avocado, susan, orez fiert, germeni de ceapă, sos ponzu – 400g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Maguro-247x247.jpeg	4	2025-03-29 17:17:57.800489	2025-03-29 17:17:57.800489
39	Poke Sake	Somon, avocado, chuka, mango copt, castraveți, roșii cherry, sos de nuci, susan, orez fiert, sos ponzu – 400g Somon, avocado, chuka, mango copt, castraveți, roșii cherry, sos de nuci, susan, orez fiert, sos ponzu – 400g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Sake-247x247.jpeg	4	2025-03-29 17:17:59.413877	2025-03-29 17:17:59.413877
40	Poke Unagi	Nori, anghila afumată, orez fiert, mango, castraveți, avocado, germeni de secară, himbir marinat, sos unagi, susan, sos ponzu – 400g Nori, anghila afumată, orez fiert, mango, castraveți, avocado, germeni de secară, himbir marinat, sos unagi, susan, sos ponzu – 400g	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Unagi-247x247.jpeg	4	2025-03-29 17:18:01.081042	2025-03-29 17:18:01.081042
41	Poke Vegetarian	Tofu, orez fiert, mango copt, edamame, roșii chery, avocado, susan alb/negru,sos ponzu, germeni de mazăre – 400g Tofu, orez fiert, mango copt, edamame, roșii chery, avocado, susan alb/negru,sos ponzu, germeni de mazăre – 400g	125.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Vegetarian-247x247.jpeg	4	2025-03-29 17:18:02.714279	2025-03-29 17:18:02.714279
42	Ebi Crunch Sushi-Burger	Ebi Crunch Sushi-Burger	180.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8518-247x247.jpeg	5	2025-03-29 17:18:06.491721	2025-03-29 17:18:06.491721
43	Ebi Tempura	Creveți, avocado, castraveti, philadelphia, panko, unagi, susan – 300/50/25/15g. Creveți, avocado, castraveti, philadelphia, panko, unagi, susan – 300/50/25/15g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ebi-Tempura-247x247.jpeg	5	2025-03-29 17:18:08.146737	2025-03-29 17:18:08.146737
44	Kani Tempura	Crab snow, castravete, avocado, philadelphia cream, susan, panko, unagi – 300/50/25/15 g. Crab snow, castravete, avocado, philadelphia cream, susan, panko, unagi – 300/50/25/15 g.	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kani-Tempura-247x247.jpeg	5	2025-03-29 17:18:09.781241	2025-03-29 17:18:09.781241
67	Miso Vegan	Tofu, vacame, susan, shitake, bulion miso – 400g Tofu, vacame, susan, shitake, bulion miso – 400g	100.00	https://ohmysushi.md/wp-content/uploads/2024/09/Miso-Vegan-247x247.jpeg	8	2025-03-29 17:18:54.022915	2025-03-29 17:18:54.022915
45	Maguro Tempura	Ton, avocado, castraveți, philadelphia, panko, unagi, susan – 300/50/25/15g. Ton, avocado, castraveți, philadelphia, panko, unagi, susan – 300/50/25/15g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/Maguro-Tempura-247x247.jpeg	5	2025-03-29 17:18:11.423812	2025-03-29 17:18:11.423812
46	Sakana Taste Sushi-Burger	Sakana Taste Sushi-Burger	162.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8519-247x247.jpeg	5	2025-03-29 17:18:13.038896	2025-03-29 17:18:13.038896
47	Sake Tempura	Somon, avocado, castraveți, philadelphia, unagi, susan, panko – 300/50/25/15 g. Somon, avocado, castraveți, philadelphia, unagi, susan, panko – 300/50/25/15 g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/22bdbe33bfabba32cd52fd27bbfa2fd3eee333972441421cedb63d799ff75c82-247x247.jpeg	5	2025-03-29 17:18:14.695847	2025-03-29 17:18:14.695847
48	Unagi Tempura	Țipar, castraveți, avocado, philadelphia, panko, unagi, susan – 300/50/25/15 g. Țipar, castraveți, avocado, philadelphia, panko, unagi, susan – 300/50/25/15 g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/Unagi-Tempura-247x247.jpeg	5	2025-03-29 17:18:16.341568	2025-03-29 17:18:16.341568
49	Ebi Hot Vulcan	Creveți, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko, micro plante – 300/50/25/15 g. Creveți, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko, micro plante – 300/50/25/15 g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ebi-Hot-Vulcan-247x247.jpeg	6	2025-03-29 17:18:19.954368	2025-03-29 17:18:19.954368
50	Kani Hot Vulcan	Crab snow,susan,avocado,castraveti,parmezan,sos spicy,parmezan,unagi,tobiko.) 300/50/25/15 gr. PREȚ- 160 MDL. Crab snow,susan,avocado,castraveti,parmezan,sos spicy,parmezan,unagi,tobiko.) 300/50/25/15 gr. PREȚ- 160 MDL.	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kani-Hot-Vulcan-247x247.jpeg	6	2025-03-29 17:18:21.56146	2025-03-29 17:18:21.56146
51	Maguro Hot Vulcan	Ton, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko, micro plante – 300/50/25/15 g. PREȚ – 165 MDL. Ton, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko, micro plante – 300/50/25/15 g. PREȚ – 165 MDL.	165.00	https://ohmysushi.md/wp-content/uploads/2024/09/Maguro-Hot-Vulcan-247x247.jpeg	6	2025-03-29 17:18:23.163665	2025-03-29 17:18:23.163665
52	Sake Hot Vulca	Somon, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko – 300/50/25/15 g. Somon, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko – 300/50/25/15 g.	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Sake-Hot-Vulca-247x247.jpeg	6	2025-03-29 17:18:24.744151	2025-03-29 17:18:24.744151
53	Unagi Hot Vulcan	Țipar, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko black – 300/50/25/15 g. Țipar, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko black – 300/50/25/15 g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/Unagi-Hot-Vulcan-247x247.jpeg	6	2025-03-29 17:18:26.373149	2025-03-29 17:18:26.373149
54	Chicken Rice	Orez, morcov, ciuperci, bostănel, ardei, carne de pui, sos thai, susan, germeni de ceapă – 370g Orez, morcov, ciuperci, bostănel, ardei, carne de pui, sos thai, susan, germeni de ceapă – 370g	100.00	https://ohmysushi.md/wp-content/uploads/2024/09/Chicken-Rice-247x247.jpeg	7	2025-03-29 17:18:30.106982	2025-03-29 17:18:30.106982
55	Midii În Sos Alb	Midii, frișcă, usturoi, vin sec alb, unt, busuioc proaspăt, germeni de ceapă – 300g Midii, frișcă, usturoi, vin sec alb, unt, busuioc proaspăt, germeni de ceapă – 300g	165.00	https://ohmysushi.md/wp-content/uploads/2024/09/Midii-In-Sos-Alb-247x247.jpeg	7	2025-03-29 17:18:31.704575	2025-03-29 17:18:31.704575
56	Midii În Sos Roșu	Midii, vin sec alb, ulei de masline, sos de roșii, usturoi, germeni de mazăre, busuioc verde – 300g Midii, vin sec alb, ulei de masline, sos de roșii, usturoi, germeni de mazăre, busuioc verde – 300g	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/Midii-In-Sos-Rosu-247x247.jpeg	7	2025-03-29 17:18:33.435253	2025-03-29 17:18:33.435253
57	Orez Beef	Mușchi de vită, ardei california, ciuperci, bostănel, morcov, susan, sos thai, germeni de ceapă – 370g Mușchi de vită, ardei california, ciuperci, bostănel, morcov, susan, sos thai, germeni de ceapă – 370g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Orez-Beef-247x247.jpeg	7	2025-03-29 17:18:35.384894	2025-03-29 17:18:35.384894
58	Orez Duck	Orez fiert, bostanel, morcov, ardei california, ciuperci, sos thai, susan, fileu de rață, germeni de ceapă, sos tiriyaki – 370g gr. Orez fiert, bostanel, morcov, ardei california, ciuperci, sos thai, susan, fileu de rață, germeni de ceapă, sos tiriyaki – 370g gr.	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Orez-Duck-247x247.jpeg	7	2025-03-29 17:18:37.028917	2025-03-29 17:18:37.028917
59	Orez Oceania	Orez, morcov, ciuperci, bostănel, ardei, cocktail fructe de mare, sos thai, susan, germenide ceapă – 370g Orez, morcov, ciuperci, bostănel, ardei, cocktail fructe de mare, sos thai, susan, germenide ceapă – 370g	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/Orez-Oceania-247x247.jpeg	7	2025-03-29 17:18:38.602645	2025-03-29 17:18:38.602645
60	Soba Beef	Soba, carne de vită, ciuperci, ardei california, bostănel, morcov, sos thai, susan, germeni de secară, sos unagi – 370g Soba, carne de vită, ciuperci, ardei california, bostănel, morcov, sos thai, susan, germeni de secară, sos unagi – 370g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Beef-247x247.jpeg	7	2025-03-29 17:18:40.299369	2025-03-29 17:18:40.299369
61	Soba Chiken	Soba, carne de pui, bostănel, morcov, ciuperci, ardei california, sos thai, susan, germeni de secară,sos unagi -370g Soba, carne de pui, bostănel, morcov, ciuperci, ardei california, sos thai, susan, germeni de secară,sos unagi -370g	120.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Chiken-247x247.jpeg	7	2025-03-29 17:18:42.045384	2025-03-29 17:18:42.045384
62	Soba Duck	Soba, piept de rață, ciuperci, ardei california, morcov, bostănel, sos thai, susan,sos tiriyaki, germeni de secară – 370g Soba, piept de rață, ciuperci, ardei california, morcov, bostănel, sos thai, susan,sos tiriyaki, germeni de secară – 370g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Duck-247x247.jpeg	7	2025-03-29 17:18:43.631486	2025-03-29 17:18:43.631486
63	Soba Oceania	Soba, coctail fructe de mare, ciuperci, ardei california, morcov, bostanel, sos thai, susan, germeni de secară, sos unagi -370g Soba, coctail fructe de mare, ciuperci, ardei california, morcov, bostanel, sos thai, susan, germeni de secară, sos unagi -370g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Oceania-247x247.jpeg	7	2025-03-29 17:18:45.315205	2025-03-29 17:18:45.315205
64	Somon Tataki	Somon fresh, susan, ulei de floarea soarelui, mix de salată, roșii cherry, sos unagi – 150/100g Somon fresh, susan, ulei de floarea soarelui, mix de salată, roșii cherry, sos unagi – 150/100g	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/Somon-Tataki-247x247.jpeg	7	2025-03-29 17:18:46.954915	2025-03-29 17:18:46.954915
65	Steak De Rață	Fileu de rață, sos teriaki, mix de verdeăță, roșii chery, susan – 150/100g Fileu de rață, sos teriaki, mix de verdeăță, roșii chery, susan – 150/100g	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/Steak-De-Rata-247x247.jpeg	7	2025-03-29 17:18:48.592704	2025-03-29 17:18:48.592704
66	Miso Fructe De Mare	Vacame, susan, shitake, bulion miso, coctail de fructe de mare – 400g Vacame, susan, shitake, bulion miso, coctail de fructe de mare – 400g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Miso-Fructe-De-Mare-247x247.jpeg	8	2025-03-29 17:18:52.382369	2025-03-29 17:18:52.382369
68	Ramen Duck	Bulion ramen, fidea, ou de găină, germeni de ceapă, carne fiartă de rață – 400g Bulion ramen, fidea, ou de găină, germeni de ceapă, carne fiartă de rață – 400g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ramen-Duck-247x247.jpeg	8	2025-03-29 17:18:55.640803	2025-03-29 17:18:55.640803
69	Tom Yum Ebi	Bulion tom yum, creveti, ciuperci, chery, susan, germeni de mazăre – 400g Bulion tom yum, creveti, ciuperci, chery, susan, germeni de mazăre – 400g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Tom-Yum-Ebi-247x247.jpeg	8	2025-03-29 17:18:57.293832	2025-03-29 17:18:57.293832
70	Том Yum Fish	Bulion tom yum, somon, biban, ciuperci, roșii cherry, germeni de ceapă – 400g Bulion tom yum, somon, biban, ciuperci, roșii cherry, germeni de ceapă – 400g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Том-Yum-Fish-247x247.jpeg	8	2025-03-29 17:18:58.88239	2025-03-29 17:18:58.88239
71	Banana Smoothie	Banana Smoothie	40.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8714-247x247.jpeg	9	2025-03-29 17:19:02.622354	2025-03-29 17:19:02.622354
72	Cappy Orange suc	500ml 500ml	25.00	https://ohmysushi.md/wp-content/uploads/2024/11/1-247x247.png	9	2025-03-29 17:19:04.243712	2025-03-29 17:19:04.243712
73	Chocolate Smoothie	Chocolate Smoothie	40.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8716-247x247.jpeg	9	2025-03-29 17:19:05.905623	2025-03-29 17:19:05.905623
74	Coca Cola Cherry	500ml 500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/2-247x247.png	9	2025-03-29 17:19:07.541272	2025-03-29 17:19:07.541272
75	Coca Cola Original	Coca Cola Original	22.00	https://ohmysushi.md/wp-content/uploads/2024/09/Coca-Cola-Original-247x247.jpeg	9	2025-03-29 17:19:09.197493	2025-03-29 17:19:09.197493
76	Coca Cola Zero	Coca Cola Zero	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/3-247x247.png	9	2025-03-29 17:19:10.923175	2025-03-29 17:19:10.923175
77	Dorna carbogazificată	500ml 500ml	15.00	https://ohmysushi.md/wp-content/uploads/2024/11/12-247x247.png	9	2025-03-29 17:19:12.499109	2025-03-29 17:19:12.499109
78	Dorna plată	500ml 500ml	15.00	https://ohmysushi.md/wp-content/uploads/2024/11/11-247x247.png	9	2025-03-29 17:19:14.195225	2025-03-29 17:19:14.195225
79	Fanta Orange	500ml 500 мл	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/4-247x247.png	9	2025-03-29 17:19:15.932755	2025-03-29 17:19:15.932755
80	Fanta Struguri	500ml 500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/6-247x247.png	9	2025-03-29 17:19:17.574874	2025-03-29 17:19:17.574874
81	Fuze Tea Mango	500ml 500ml	20.00	https://ohmysushi.md/wp-content/uploads/2024/11/7-247x247.png	9	2025-03-29 17:19:19.231402	2025-03-29 17:19:19.231402
82	Fuze Tea Peach	500ml 500ml	20.00	https://ohmysushi.md/wp-content/uploads/2024/11/8-247x247.png	9	2025-03-29 17:19:20.850896	2025-03-29 17:19:20.850896
83	Classic Cheesecake	Classic Cheesecake	90.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8724-247x247.jpeg	10	2025-03-29 17:19:24.505411	2025-03-29 17:19:24.505411
84	Mousse Cheesecake	Mousse Cheesecake	85.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8719-247x247.jpeg	10	2025-03-29 17:19:26.172622	2025-03-29 17:19:26.172622
85	Napoleon	Napoleon	85.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8718-247x247.jpeg	10	2025-03-29 17:19:27.814531	2025-03-29 17:19:27.814531
86	Tiramisu	Tiramisu	80.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8720-247x247.jpeg	10	2025-03-29 17:19:29.452664	2025-03-29 17:19:29.452664
87	Ebi Crunch Sushi-Burger	Ebi Crunch Sushi-Burger	180.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8518-247x247.jpeg	11	2025-03-29 17:19:33.35018	2025-03-29 17:19:33.35018
88	Napoleon	Napoleon	85.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8718-247x247.jpeg	11	2025-03-29 17:19:34.980354	2025-03-29 17:19:34.980354
89	Sakana Taste Sushi-Burger	Sakana Taste Sushi-Burger	162.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8519-247x247.jpeg	11	2025-03-29 17:19:36.631987	2025-03-29 17:19:36.631987
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, telegram_id, first_name, last_name, username, language, created_at, updated_at) FROM stdin;
1	444940427	Ivan	Teaca	\N	ru	2025-03-29 17:21:43.298918	2025-03-29 17:21:43.298918
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 12, false);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 11, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 11, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 90, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, false);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_order_items_on_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_order_items_on_order_id ON public.order_items USING btree (order_id);


--
-- Name: index_order_items_on_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_order_items_on_product_id ON public.order_items USING btree (product_id);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_orders_on_user_id ON public.orders USING btree (user_id);


--
-- Name: index_products_on_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_products_on_category_id ON public.products USING btree (category_id);


--
-- Name: products fk_rails_fb915499a4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_rails_fb915499a4 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- PostgreSQL database dump complete
--

