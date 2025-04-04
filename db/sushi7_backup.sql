qgHeP7KiUgJXmLMtMfvx--
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: ivan
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO ivan;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: ivan
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying,
    url_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.categories OWNER TO ivan;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: ivan
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO ivan;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ivan
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: ivan
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


ALTER TABLE public.order_items OWNER TO ivan;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: ivan
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_id_seq OWNER TO ivan;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ivan
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: ivan
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


ALTER TABLE public.orders OWNER TO ivan;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: ivan
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO ivan;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ivan
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: ivan
--

CREATE TABLE public.product_categories (
    id bigint NOT NULL,
    product_id bigint,
    category_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.product_categories OWNER TO ivan;

--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: ivan
--

CREATE SEQUENCE public.product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_categories_id_seq OWNER TO ivan;

--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ivan
--

ALTER SEQUENCE public.product_categories_id_seq OWNED BY public.product_categories.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: ivan
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    name character varying,
    description text,
    price numeric(10,2),
    image_url character varying,
    category_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    is_sale boolean DEFAULT false,
    original_price numeric(10,2),
    sale_price numeric(10,2)
);


ALTER TABLE public.products OWNER TO ivan;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: ivan
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO ivan;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ivan
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: ivan
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO ivan;

--
-- Name: users; Type: TABLE; Schema: public; Owner: ivan
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    telegram_id bigint,
    first_name character varying,
    last_name character varying,
    username character varying,
    language character varying DEFAULT 'ru'::character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO ivan;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: ivan
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO ivan;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ivan
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: product_categories id; Type: DEFAULT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.product_categories ALTER COLUMN id SET DEFAULT nextval('public.product_categories_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2025-04-03 12:26:09.760258	2025-04-03 12:26:09.760265
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.categories (id, name, url_name, created_at, updated_at) FROM stdin;
1	🍱 Сеты	seturi	2025-04-04 12:49:03.892716	2025-04-04 12:49:03.892716
2	🍣 Суши	sushi	2025-04-04 12:49:03.898631	2025-04-04 12:49:03.898631
3	🍙 Маки-Нигири-Гункан	maki-nigiri-guncan	2025-04-04 12:49:03.899617	2025-04-04 12:49:03.899617
4	🥗 Поке Боул	poke-bowl	2025-04-04 12:49:03.900408	2025-04-04 12:49:03.900408
5	🍤 Темпура	tempura	2025-04-04 12:49:03.901133	2025-04-04 12:49:03.901133
6	🌋 Вулкан	vulcan	2025-04-04 12:49:03.902379	2025-04-04 12:49:03.902379
7	🥢 Вок	wok	2025-04-04 12:49:03.903447	2025-04-04 12:49:03.903447
8	🥣 Супы	supe	2025-04-04 12:49:03.904615	2025-04-04 12:49:03.904615
9	🥤 Напитки	bauturi	2025-04-04 12:49:03.905674	2025-04-04 12:49:03.905674
10	🍰 Десерты	dessert-2	2025-04-04 12:49:03.90656	2025-04-04 12:49:03.90656
11	🏷️ Акции	reduceri	2025-04-04 12:49:03.907526	2025-04-04 12:49:03.907526
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.order_items (id, order_id, product_id, quantity, price, created_at, updated_at) FROM stdin;
5	1	363	2	1850.0	2025-04-04 12:40:13.809384	2025-04-04 12:40:15.597738
6	1	424	2	150.0	2025-04-04 12:40:23.484479	2025-04-04 12:40:34.134819
7	2	18	1	165.0	2025-04-04 14:10:33.416711	2025-04-04 14:10:33.416711
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.orders (id, user_id, status, phone, address, comment, payment_method, checkout_step, payment_id, payment_status, created_at, updated_at) FROM stdin;
2	1	cart	\N	\N	\N	\N	\N	\N	\N	2025-04-04 12:40:50.205543	2025-04-04 12:40:50.205543
1	1	accepted	067986786	yyuyuk	uu	cash	comment	\N	\N	2025-04-04 08:00:44.966471	2025-04-04 12:40:54.941405
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.product_categories (id, product_id, category_id, created_at, updated_at) FROM stdin;
2	1	1	2025-04-04 11:05:02.035548	2025-04-04 11:05:02.035548
3	97	33	2025-04-04 08:27:54.334097	2025-04-04 08:27:54.334097
4	131	33	2025-04-04 08:29:02.903272	2025-04-04 08:29:02.903272
5	135	33	2025-04-04 08:29:09.865999	2025-04-04 08:29:09.865999
6	176	33	2025-04-04 08:30:33.956	2025-04-04 08:30:33.956
7	178	33	2025-04-04 08:30:37.397931	2025-04-04 08:30:37.397931
8	186	44	2025-04-04 08:38:22.586589	2025-04-04 08:38:22.586589
9	220	44	2025-04-04 08:39:30.553124	2025-04-04 08:39:30.553124
10	224	44	2025-04-04 08:39:37.64118	2025-04-04 08:39:37.64118
11	265	44	2025-04-04 08:41:04.640409	2025-04-04 08:41:04.640409
12	267	44	2025-04-04 08:41:08.099824	2025-04-04 08:41:08.099824
13	275	55	2025-04-04 09:43:55.090655	2025-04-04 09:43:55.090655
14	309	55	2025-04-04 09:45:06.450372	2025-04-04 09:45:06.450372
15	313	55	2025-04-04 09:45:13.437739	2025-04-04 09:45:13.437739
16	354	55	2025-04-04 09:46:40.871733	2025-04-04 09:46:40.871733
17	356	55	2025-04-04 09:46:44.349533	2025-04-04 09:46:44.349533
18	364	66	2025-04-04 10:10:30.768228	2025-04-04 10:10:30.768228
19	398	66	2025-04-04 10:11:40.015949	2025-04-04 10:11:40.015949
20	402	66	2025-04-04 10:11:47.210447	2025-04-04 10:11:47.210447
21	8	11	2025-04-04 12:49:19.24386	2025-04-04 12:49:19.24386
22	42	11	2025-04-04 12:50:27.113242	2025-04-04 12:50:27.113242
23	46	11	2025-04-04 12:50:34.173465	2025-04-04 12:50:34.173465
25	89	11	2025-04-04 14:07:48.558898	2025-04-04 14:07:48.558898
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.products (id, name, description, price, image_url, category_id, created_at, updated_at, is_sale, original_price, sale_price) FROM stdin;
27	Ebi Mak	Creveți, susan, orez, nori, vasabi, ghimbir, sos de soia – 140/50/25/15 g.	80.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ebi-Mak-247x247.jpeg	3	2025-04-04 12:49:56.895175	2025-04-04 12:49:56.895175	f	80.00	80.00
37	Poke Ebi	Creveți fierți, edamame, mango copt, roșii chery, avocado, icre tobiko, orez fiert, sos ponzu, sos spicy, germeni din ceapă – 400g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Ebi-247x247.jpeg	4	2025-04-04 12:50:16.461678	2025-04-04 12:50:16.461678	f	145.00	145.00
38	Poke Maguro	Ton, edamame, nori, mango copt, avocado, susan, orez fiert, germeni de ceapă, sos ponzu – 400g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Maguro-247x247.jpeg	4	2025-04-04 12:50:18.112513	2025-04-04 12:50:18.112513	f	150.00	150.00
39	Poke Sake	Somon, avocado, chuka, mango copt, castraveți, roșii cherry, sos de nuci, susan, orez fiert, sos ponzu – 400g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Sake-247x247.jpeg	4	2025-04-04 12:50:19.832463	2025-04-04 12:50:19.832463	f	145.00	145.00
40	Poke Unagi	Nori, anghila afumată, orez fiert, mango, castraveți, avocado, germeni de secară, himbir marinat, sos unagi, susan, sos ponzu – 400g	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Unagi-247x247.jpeg	4	2025-04-04 12:50:21.505505	2025-04-04 12:50:21.505505	f	155.00	155.00
41	Poke Vegetarian	Tofu, orez fiert, mango copt, edamame, roșii chery, avocado, susan alb/negru,sos ponzu, germeni de mazăre – 400g	125.00	https://ohmysushi.md/wp-content/uploads/2024/09/Poke-Vegetarian-247x247.jpeg	4	2025-04-04 12:50:23.210653	2025-04-04 12:50:23.210653	f	125.00	125.00
43	Ebi Tempura	Creveți, avocado, castraveti, philadelphia, panko, unagi, susan – 300/50/25/15g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ebi-Tempura-247x247.jpeg	5	2025-04-04 12:50:28.908052	2025-04-04 12:50:28.908052	f	180.00	180.00
44	Kani Tempura	Crab snow, castravete, avocado, philadelphia cream, susan, panko, unagi – 300/50/25/15 g.	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kani-Tempura-247x247.jpeg	5	2025-04-04 12:50:30.624341	2025-04-04 12:50:30.624341	f	160.00	160.00
45	Maguro Tempura	Ton, avocado, castraveți, philadelphia, panko, unagi, susan – 300/50/25/15g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/Maguro-Tempura-247x247.jpeg	5	2025-04-04 12:50:32.436638	2025-04-04 12:50:32.436638	f	180.00	180.00
46	Sakana Taste Sushi-Burger	Sakana Taste Sushi-Burger	162.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8519-247x247.jpeg	5	2025-04-04 12:50:34.163354	2025-04-04 12:50:34.163354	t	180.00	162.00
47	Sake Tempura	Somon, avocado, castraveți, philadelphia, unagi, susan, panko – 300/50/25/15 g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/22bdbe33bfabba32cd52fd27bbfa2fd3eee333972441421cedb63d799ff75c82-247x247.jpeg	5	2025-04-04 12:50:35.813724	2025-04-04 12:50:35.813724	f	180.00	180.00
48	Unagi Tempura	Țipar, castraveți, avocado, philadelphia, panko, unagi, susan – 300/50/25/15 g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/Unagi-Tempura-247x247.jpeg	5	2025-04-04 12:50:37.537909	2025-04-04 12:50:37.537909	f	170.00	170.00
49	Ebi Hot Vulcan	Creveți, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko, micro plante – 300/50/25/15 g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ebi-Hot-Vulcan-247x247.jpeg	6	2025-04-04 12:50:41.403641	2025-04-04 12:50:41.403641	f	170.00	170.00
50	Kani Hot Vulcan	Crab snow,susan,avocado,castraveti,parmezan,sos spicy,parmezan,unagi,tobiko.) 300/50/25/15 gr. PREȚ- 160 MDL.	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kani-Hot-Vulcan-247x247.jpeg	6	2025-04-04 12:50:43.054357	2025-04-04 12:50:43.054357	f	160.00	160.00
51	Maguro Hot Vulcan	Ton, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko, micro plante – 300/50/25/15 g. PREȚ – 165 MDL.	165.00	https://ohmysushi.md/wp-content/uploads/2024/09/Maguro-Hot-Vulcan-247x247.jpeg	6	2025-04-04 12:50:44.816488	2025-04-04 12:50:44.816488	f	165.00	165.00
52	Sake Hot Vulca	Somon, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko – 300/50/25/15 g.	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Sake-Hot-Vulca-247x247.jpeg	6	2025-04-04 12:50:46.55044	2025-04-04 12:50:46.55044	f	160.00	160.00
53	Unagi Hot Vulcan	Țipar, susan, avocado, castraveți, parmezan, sos spicy, unagi, tobiko black – 300/50/25/15 g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/Unagi-Hot-Vulcan-247x247.jpeg	6	2025-04-04 12:50:48.285066	2025-04-04 12:50:48.285066	f	170.00	170.00
54	Chicken Rice	Orez, morcov, ciuperci, bostănel, ardei, carne de pui, sos thai, susan, germeni de ceapă – 370g	100.00	https://ohmysushi.md/wp-content/uploads/2024/09/Chicken-Rice-247x247.jpeg	7	2025-04-04 12:50:52.241926	2025-04-04 12:50:52.241926	f	100.00	100.00
55	Midii În Sos Alb	Midii, frișcă, usturoi, vin sec alb, unt, busuioc proaspăt, germeni de ceapă – 300g	165.00	https://ohmysushi.md/wp-content/uploads/2024/09/Midii-In-Sos-Alb-247x247.jpeg	7	2025-04-04 12:50:54.03104	2025-04-04 12:50:54.03104	f	165.00	165.00
56	Midii În Sos Roșu	Midii, vin sec alb, ulei de masline, sos de roșii, usturoi, germeni de mazăre, busuioc verde – 300g	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/Midii-In-Sos-Rosu-247x247.jpeg	7	2025-04-04 12:50:55.76961	2025-04-04 12:50:55.76961	f	155.00	155.00
57	Orez Beef	Mușchi de vită, ardei california, ciuperci, bostănel, morcov, susan, sos thai, germeni de ceapă – 370g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Orez-Beef-247x247.jpeg	7	2025-04-04 12:50:57.611493	2025-04-04 12:50:57.611493	f	145.00	145.00
28	Gnkan Unagi	Orez, nori, anghila, sos spicy, unagi – 1/60g	65.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gnkan-Unagi-247x247.jpeg	3	2025-04-04 12:49:58.63229	2025-04-04 12:49:58.63229	f	65.00	65.00
29	Gunkan EBI	Orez, nori, creveți, sos spicy – 1/60g	55.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-EBI-247x247.jpeg	3	2025-04-04 12:50:00.296372	2025-04-04 12:50:00.296372	f	55.00	55.00
30	Gunkan Maguro	Orez, nori, ton, sos spicy – 1/60g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-Maguro-247x247.jpeg	3	2025-04-04 12:50:02.22933	2025-04-04 12:50:02.22933	f	50.00	50.00
31	Gunkan Sake	Orez, nori, somon, sos spicy -1/60g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-Sake-247x247.jpeg	3	2025-04-04 12:50:03.932988	2025-04-04 12:50:03.932988	f	50.00	50.00
32	Gunkan Tobico	Orez, nori, icre de pește zburător – 1/60g	75.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkan-Tobico-247x247.jpeg	3	2025-04-04 12:50:05.665621	2025-04-04 12:50:05.665621	f	75.00	75.00
33	Gunkn Caviar	Orez, nori, caviar de somon – 1/60g	90.00	https://ohmysushi.md/wp-content/uploads/2024/09/Gunkn-Caviar-247x247.jpeg	3	2025-04-04 12:50:07.398106	2025-04-04 12:50:07.398106	f	90.00	90.00
35	Kappa Maki	Castraveți, orez, susan, nori, vasabi, ghimbir, sos soia – 140/50/25/15g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kappa-Maki-247x247.jpeg	3	2025-04-04 12:50:10.929653	2025-04-04 12:50:10.929653	f	50.00	50.00
36	Nigiri BURNT	Orez cu somon grill – 1/35g	50.00	https://ohmysushi.md/wp-content/uploads/2024/09/Nigiri-BURNT-247x247.jpeg	3	2025-04-04 12:50:12.63351	2025-04-04 12:50:12.63351	f	50.00	50.00
42	Ebi Crunch Sushi-Burger	Black rice, tempura prawns, avocado, cucumbers, salad leaves, special sauce	180.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8518-247x247.jpeg	5	2025-04-04 12:50:27.10088	2025-04-04 12:50:27.10088	t	200.00	180.00
117	Nigiri Unagi	Orez, anghila, nori, unagi – 1/35g	55.00	https://ohmysushi.md/wp-content/uploads/2024/09/Nigiri-Unagi-247x247.jpeg	3	2025-04-04 14:09:03.805345	2025-04-04 14:09:03.805345	f	55.00	55.00
58	Orez Duck	Orez fiert, bostanel, morcov, ardei california, ciuperci, sos thai, susan, fileu de rață, germeni de ceapă, sos tiriyaki – 370g gr.	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Orez-Duck-247x247.jpeg	7	2025-04-04 12:50:59.360036	2025-04-04 12:50:59.360036	f	145.00	145.00
59	Orez Oceania	Orez, morcov, ciuperci, bostănel, ardei, cocktail fructe de mare, sos thai, susan, germenide ceapă – 370g	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/Orez-Oceania-247x247.jpeg	7	2025-04-04 12:51:01.03052	2025-04-04 12:51:01.03052	f	155.00	155.00
60	Soba Beef	Soba, carne de vită, ciuperci, ardei california, bostănel, morcov, sos thai, susan, germeni de secară, sos unagi – 370g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Beef-247x247.jpeg	7	2025-04-04 12:51:02.727008	2025-04-04 12:51:02.727008	f	145.00	145.00
61	Soba Chiken	Soba, carne de pui, bostănel, morcov, ciuperci, ardei california, sos thai, susan, germeni de secară,sos unagi -370g	120.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Chiken-247x247.jpeg	7	2025-04-04 12:51:04.442159	2025-04-04 12:51:04.442159	f	120.00	120.00
62	Soba Duck	Soba, piept de rață, ciuperci, ardei california, morcov, bostănel, sos thai, susan,sos tiriyaki, germeni de secară – 370g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Duck-247x247.jpeg	7	2025-04-04 12:51:06.135973	2025-04-04 12:51:06.135973	f	150.00	150.00
63	Soba Oceania	Soba, coctail fructe de mare, ciuperci, ardei california, morcov, bostanel, sos thai, susan, germeni de secară, sos unagi -370g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Soba-Oceania-247x247.jpeg	7	2025-04-04 12:51:07.855337	2025-04-04 12:51:07.855337	f	160.00	160.00
64	Somon Tataki	Somon fresh, susan, ulei de floarea soarelui, mix de salată, roșii cherry, sos unagi – 150/100g	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/Somon-Tataki-247x247.jpeg	7	2025-04-04 12:51:09.59767	2025-04-04 12:51:09.59767	f	195.00	195.00
65	Steak De Rață	Fileu de rață, sos teriaki, mix de verdeăță, roșii chery, susan – 150/100g	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/Steak-De-Rata-247x247.jpeg	7	2025-04-04 12:51:11.282219	2025-04-04 12:51:11.282219	f	200.00	200.00
66	Miso Fructe De Mare	Vacame, susan, shitake, bulion miso, coctail de fructe de mare – 400g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Miso-Fructe-De-Mare-247x247.jpeg	8	2025-04-04 12:51:15.131899	2025-04-04 12:51:15.131899	f	150.00	150.00
67	Miso Vegan	Tofu, vacame, susan, shitake, bulion miso – 400g	100.00	https://ohmysushi.md/wp-content/uploads/2024/09/Miso-Vegan-247x247.jpeg	8	2025-04-04 12:51:16.8596	2025-04-04 12:51:16.8596	f	100.00	100.00
68	Ramen Duck	Bulion ramen, fidea, ou de găină, germeni de ceapă, carne fiartă de rață – 400g	150.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ramen-Duck-247x247.jpeg	8	2025-04-04 12:51:18.600526	2025-04-04 12:51:18.600526	f	150.00	150.00
69	Tom Yum Ebi	Bulion tom yum, creveti, ciuperci, chery, susan, germeni de mazăre – 400g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Tom-Yum-Ebi-247x247.jpeg	8	2025-04-04 12:51:20.343901	2025-04-04 12:51:20.343901	f	160.00	160.00
70	Том Yum Fish	Bulion tom yum, somon, biban, ciuperci, roșii cherry, germeni de ceapă – 400g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Том-Yum-Fish-247x247.jpeg	8	2025-04-04 12:51:22.085924	2025-04-04 12:51:22.085924	f	160.00	160.00
72	Cappy Orange suc	500ml	25.00	https://ohmysushi.md/wp-content/uploads/2024/11/1-247x247.png	9	2025-04-04 12:51:27.637157	2025-04-04 12:51:27.637157	f	25.00	25.00
74	Coca Cola Cherry	500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/2-247x247.png	9	2025-04-04 12:51:31.094426	2025-04-04 12:51:31.094426	f	22.00	22.00
77	Dorna carbogazificată	500ml	15.00	https://ohmysushi.md/wp-content/uploads/2024/11/12-247x247.png	9	2025-04-04 12:51:36.248588	2025-04-04 12:51:36.248588	f	15.00	15.00
78	Dorna plată	500ml	15.00	https://ohmysushi.md/wp-content/uploads/2024/11/11-247x247.png	9	2025-04-04 12:51:37.9592	2025-04-04 12:51:37.9592	f	15.00	15.00
79	Fanta Orange	500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/4-247x247.png	9	2025-04-04 12:51:39.70192	2025-04-04 12:51:39.70192	f	22.00	22.00
80	Fanta Struguri	500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/6-247x247.png	9	2025-04-04 12:51:41.650691	2025-04-04 12:51:41.650691	f	22.00	22.00
81	Fuze Tea Mango	500ml	20.00	https://ohmysushi.md/wp-content/uploads/2024/11/7-247x247.png	9	2025-04-04 12:51:43.322258	2025-04-04 12:51:43.322258	f	20.00	20.00
82	Fuze Tea Peach	500ml	20.00	https://ohmysushi.md/wp-content/uploads/2024/11/8-247x247.png	9	2025-04-04 12:51:45.007371	2025-04-04 12:51:45.007371	f	20.00	20.00
83	Classic Cheesecake	Classic Cheesecake	90.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8724-247x247.jpeg	10	2025-04-04 12:51:48.807441	2025-04-04 12:51:48.807441	f	90.00	90.00
84	Mousse Cheesecake	Mousse Cheesecake	85.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8719-247x247.jpeg	10	2025-04-04 12:51:50.554463	2025-04-04 12:51:50.554463	f	85.00	85.00
85	Napoleon	Napoleon	85.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8718-247x247.jpeg	10	2025-04-04 12:51:52.212426	2025-04-04 12:51:52.212426	f	85.00	85.00
26	Chuka Maki	Chuka, orez, nori, susan, sos de nuci, vasabi, ghimbir, sos soia – 140/50/25/15g	67.00	https://ohmysushi.md/wp-content/uploads/2024/09/Chuka-Maki-247x247.jpeg	3	2025-04-04 12:49:55.154964	2025-04-04 12:49:55.154964	f	67.00	67.00
86	Tiramisu	Tiramisu	80.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8720-247x247.jpeg	10	2025-04-04 12:51:53.930629	2025-04-04 12:51:53.930629	f	80.00	80.00
34	Kani Maki	Crab snow, susan, nori, unagi, vasabi, ghimbir, sos soia.)- 140/50/25/15g	65.00	https://ohmysushi.md/wp-content/uploads/2024/09/Kani-Maki-247x247.jpeg	3	2025-04-04 12:50:09.184086	2025-04-04 12:50:09.184086	f	65.00	65.00
71	Banana Smoothie	500ml	40.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8714-247x247.jpeg	9	2025-04-04 12:51:25.978378	2025-04-04 12:51:25.978378	f	40.00	40.00
73	Chocolate Smoothie	500ml	40.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8716-247x247.jpeg	9	2025-04-04 12:51:29.365171	2025-04-04 12:51:29.365171	f	40.00	40.00
75	Coca Cola Original	500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/09/Coca-Cola-Original-247x247.jpeg	9	2025-04-04 12:51:32.841049	2025-04-04 12:51:32.841049	f	22.00	22.00
76	Coca Cola Zero	500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/3-247x247.png	9	2025-04-04 12:51:34.587799	2025-04-04 12:51:34.587799	f	22.00	22.00
112	Philadelphia unagi	Somon, țipar, avocado, castraveți, philadelphia cream, sos unagi – 290/50/25/15gr.	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/6acca096706b8d08dcb9811092fc228cab92f2c94a062d6fcef32caf4879a6f3-247x247.jpg	2	2025-04-04 14:08:48.412643	2025-04-04 14:08:48.412643	f	195.00	195.00
113	Sake dragon	Somon, tobico, țipar, avocado, castraveți, philadelphia cream, micro plante – 300/50/25/15g.	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/cfe20915424b02d2b9da02b8c17a278d60a05350356811e444ef401a63bc8a7d-247x247.jpg	2	2025-04-04 14:08:50.182868	2025-04-04 14:08:50.182868	f	200.00	200.00
114	Nigiri Ebi	Orez cu creveți – 1/35 g	45.00	https://ohmysushi.md/wp-content/uploads/2024/09/Nigiri-Ebi-247x247.jpeg	3	2025-04-04 14:08:58.568607	2025-04-04 14:08:58.568607	f	45.00	45.00
115	Nigiri Maguro	Orez, ton – 1/35g	55.00	https://ohmysushi.md/wp-content/uploads/2024/09/Nigiri-Maguro-247x247.jpeg	3	2025-04-04 14:09:00.319116	2025-04-04 14:09:00.319116	f	55.00	55.00
116	Nigiri Sake	Orez, somon – 1/35 g	45.00	https://ohmysushi.md/wp-content/uploads/2024/09/Nigiri-Sake-247x247.jpeg	3	2025-04-04 14:09:02.034981	2025-04-04 14:09:02.034981	f	45.00	45.00
105	Hadaka unagi	Susan amestic, parmezan, lola, castraveți, țipar, roșii, sos spaisy, micro verdeață – 280/50/25/15 g.	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/0de6074fdd59df251f53b811569-247x247.jpg	2	2025-04-04 14:08:33.918655	2025-04-04 14:08:33.918655	f	145.00	145.00
106	Huge Samurai	Huge Samurai	270.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8775-1-247x247.jpeg	2	2025-04-04 14:08:35.752155	2025-04-04 14:08:35.752155	f	270.00	270.00
107	Imperator	Criveți, somon, avocado, castraveți, philadelphia cream – 300/50/25/15 g.	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/b026ad47f53fa793232de36d7e09a961ee7f279caf9244f36f05c8451d23bc98-247x247.jpg	2	2025-04-04 14:08:37.491025	2025-04-04 14:08:37.491025	f	200.00	200.00
1	Big party pack set	Canada, Imperial roll, Philadelphia ebi, California black&white, Unagi tempura, Kani hot vulcan, Sake maki, Kappa maki – 1700/150/75/60 g, 64 buc	1000.00	https://ohmysushi.md/wp-content/uploads/2024/09/d2b47005ce2edbe8d970381be7dccab1420b339be51994d7006c4ecb144c8955-247x247.jpg	1	2025-04-04 12:49:07.108369	2025-04-04 12:54:54.254044	f	1000.00	1000.00
90	Set katana	Brunt sake, chedar roll, california kani white, ebi tempura, sake tempura, nigiri sake,nigiri maguro, nigiri ebi – 1600/200/100/60g 43 buc.	880.00	https://ohmysushi.md/wp-content/uploads/2024/09/eed535b2bae129aad9db398ca928ae4feb9e4ef52ccf079db37eb4515869dfeb-247x247.jpg	1	2025-04-04 14:07:52.473818	2025-04-04 14:07:52.473818	f	880.00	880.00
91	Set sunakku	Philadelphia, California black & white, kappa maki – 700/60/30/15G 24 buc.	390.00	https://ohmysushi.md/wp-content/uploads/2024/09/663ec8aa8f87b0ce6c75253814076336eea78e3597af00276ade8f7d6c2ccb57-247x247.jpg	1	2025-04-04 14:07:54.278975	2025-04-04 14:07:54.278975	f	390.00	390.00
92	Set zen	Green dragon, california, philadelphia, sake maki, kappa maki – 1140/100/60/40g 40 buc.	600.00	https://ohmysushi.md/wp-content/uploads/2024/09/ddfbc6a73e46da280a316433e9df64bee46b34db23368e8f5cbe759faa0424e3-247x247.jpg	1	2025-04-04 14:07:56.115812	2025-04-04 14:07:56.115812	f	600.00	600.00
93	Snack set	Sake Tempura, Sake Hot Vulcan, Sake Maki – 740/60/30/30g 24buc	385.00	https://ohmysushi.md/wp-content/uploads/2024/09/288e250b9175c73145d1be7b0b5d29b414d0736abe93406810b0ba2cd1f5c6ad-247x247.jpg	1	2025-04-04 14:07:57.963675	2025-04-04 14:07:57.963675	f	385.00	385.00
94	Tempura set	Sake tempura, kani tempura, maguro tempura – 900/100/60/30g 24buc	450.00	https://ohmysushi.md/wp-content/uploads/2024/09/3b0b61f8a8de27c489af3dca84761a98792c728735b76180c9fa93cc06a1d48d-247x247.jpg	1	2025-04-04 14:07:59.718436	2025-04-04 14:07:59.718436	f	450.00	450.00
95	Top set	Philadelphia, California, California black & white – 840/60/30/30g 24buc	450.00	https://ohmysushi.md/wp-content/uploads/2024/09/8e23de7a1ed17d311c1e63df7c391d65be35813b267eaf0340ec8be1a822813e-247x247.jpg	1	2025-04-04 14:08:01.546435	2025-04-04 14:08:01.546435	f	450.00	450.00
96	Crispy Golden Noel	Crispy Golden Noel	250.00	https://ohmysushi.md/wp-content/uploads/2024/12/img_8079-247x247.jpeg	2	2025-04-04 14:08:09.852276	2025-04-04 14:08:09.852276	f	250.00	250.00
97	Fusion	Mango, avocado, creveți tempura, philadelphia cream, sos unagi, toping de căpșună – 280/50/25/15 g.	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/7124a8a9983e447140e4080487f8f971c61f84522f136584feb227b9496e6862-247x247.jpg	2	2025-04-04 14:08:11.686763	2025-04-04 14:08:11.686763	f	195.00	195.00
98	Golden dragon	Țipar, tobico, somon, avocado, philadelphia cream, sos unagi, susan, micro plante – 300/50/25/15 g.	225.00	https://ohmysushi.md/wp-content/uploads/2024/09/7254205deb9211f2d10c9c83d6c5b1916de28c13c565697ac0547c66498c3c50-247x247.jpg	2	2025-04-04 14:08:21.514623	2025-04-04 14:08:21.514623	f	225.00	225.00
100	Green dragon	Avocado, castraveți, crevete, philadelphia cream, tobico, unagi, susan, micro plante – 300/50/25/15g.	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/14ea0ea464c6ab6b704b5f096a9bf1a6cc21edff30129196fabb4c006ac7b97a-247x247.jpg	2	2025-04-04 14:08:25.099579	2025-04-04 14:08:25.099579	f	195.00	195.00
101	Hadaka chicken	Susan, amestic, parmezan, lola, castraveți, pui pane, roșii, sos spaisy, micro verdeața – 280/50/25/15 g.	135.00	https://ohmysushi.md/wp-content/uploads/2024/09/e02ded5945ed04b300be5e21d91502f80d5ddf54931562fa8f9739cfb96a79c1-247x247.jpg	2	2025-04-04 14:08:26.936801	2025-04-04 14:08:26.936801	f	135.00	135.00
102	Hadaka ebi	Susan, amestic, parmezan, lola, castraveți, creveți, roșii, sos spaisy, micro verdeață – 280/50/25/15 g.	155.00	https://ohmysushi.md/wp-content/uploads/2024/09/e387f814c8bb59f5f8bce2242acb6f69b7de50de6074fdd59df251f53b811569-247x247.jpg	2	2025-04-04 14:08:28.680548	2025-04-04 14:08:28.680548	f	155.00	155.00
103	Hadaka Kani	Susan, amestic, parmezan, lola, castraveții, snow crab, roșii, sos spaisy, micro verdeață – 280/50/25/15 g.	135.00	https://ohmysushi.md/wp-content/uploads/2024/09/e02ded5945ed04b300be5e21d91502f80d5ddf54931562fa8f9739cfb96a79c1-247x247.jpeg	2	2025-04-04 14:08:30.425759	2025-04-04 14:08:30.425759	f	135.00	135.00
104	Hadaka sake	Susan amestic, parmezan, lola, castraveți, somon, roșii, sos spaisy, micro verdeață – 280/50/25/15 g.	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/e387f814c8bb59f5f8bce2242acb6f69b7de50de6074fdd59df251f53b811569-1-247x247.jpg	2	2025-04-04 14:08:32.163397	2025-04-04 14:08:32.163397	f	145.00	145.00
108	Maguro dragon	Ton, caviar, avocado, mango, philadelphia cream, micro plante – 300/30/15/15g.	215.00	https://ohmysushi.md/wp-content/uploads/2024/09/bcf3681916544ded940abf9f33e2ba2ea482b58342c2531616cd93e6637f6834-247x247.jpg	2	2025-04-04 14:08:41.493135	2025-04-04 14:08:41.493135	f	215.00	215.00
109	Philadelphia caviar	Somon, avocado, castraveți, philadelphia cream,caviar – 300/50/25/15g.	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/f68725814976eedb48d0599b460fc2ccececa387c9789c87409aa1fd5af69da4-247x247.jpg	2	2025-04-04 14:08:43.227297	2025-04-04 14:08:43.227297	f	200.00	200.00
110	Philadelphia classic	Somon, avocado, castravete, philadelphia cream. 280/50/25/15g	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/6d2eab5c4b0b65c628f54f4ae27fa2d46c638c0abc41e4bb6065ab09447235b2-247x247.jpg	2	2025-04-04 14:08:44.935931	2025-04-04 14:08:44.935931	f	180.00	180.00
111	Philadelphia ebi	Somon, creveții, avocado, philadelphia cream – 280/50/25/15 gr.	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/554556a9726a054a24689038ad8720e29e96cb610b15be32ccffee13d889cebf-247x247.jpg	2	2025-04-04 14:08:46.701292	2025-04-04 14:08:46.701292	f	195.00	195.00
99	Golden rainbow	Gold, tempura prawns, half salmon, half maguro, cucumbers, cream cheese, tobiko	280.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8503-247x247.jpeg	2	2025-04-04 14:08:23.288315	2025-04-04 14:08:23.288315	f	280.00	280.00
2	California set	California classic, california kani white, california sake, california black & white. 32 buc.	580.00	https://ohmysushi.md/wp-content/uploads/2024/09/9b6b8fffe6caea9bc17898cdbdc33172674c695862d4a28eded6bef463f41e73-247x247.jpg	1	2025-04-04 12:49:08.874269	2025-04-04 12:49:08.874269	f	580.00	580.00
3	Dragon set	Golden dragon, red dragon, green dragon, sake dragon – 1.200/120/75/75g 32 buc.	750.00	https://ohmysushi.md/wp-content/uploads/2024/09/9d40c7873fb32e2f13ff8919824fb7484da561cab7dba2219fc645756c1c6994-247x247.jpg	1	2025-04-04 12:49:10.606528	2025-04-04 12:49:10.606528	f	750.00	750.00
5	Maki set	Maguro maki, kappa maki, ebi maki, sake maki, avocado maki – 700/100/50/30g 40 buc.	300.00	https://ohmysushi.md/wp-content/uploads/2024/09/7964e13e78b258174357c8cb50468baa2c3bb8ff8fbb767952e865ce417363ab-247x247.jpg	1	2025-04-04 12:49:13.933984	2025-04-04 12:49:13.933984	f	300.00	300.00
10	Philadelphia set	Philadelphia, philadelphia de lux, philadelphia ebi – 870/60/30/30g 24buc	500.00	https://ohmysushi.md/wp-content/uploads/2024/09/70dd6e9dfab69fffb28748d2f42b0a3fe2877acf6f13cdb21f589be4b52d941e-247x247.jpg	1	2025-04-04 12:49:22.891754	2025-04-04 12:49:22.891754	f	500.00	500.00
11	Set aiko	Philadelphia, california kani white, teriyaki maki – 700/100/30/15g 24 buc	360.00	https://ohmysushi.md/wp-content/uploads/2024/09/1a26e9c1507ba81d965bc854c1d8b9d08830ebf2ff5090b867f8b389c18d8f4d-247x247.jpg	1	2025-04-04 12:49:24.631498	2025-04-04 12:49:24.631498	f	360.00	360.00
12	Set art	Canada, california classic, nigiri sake, nigiri maguro, nigiri ebi, hadaka sake, hadaka maguro, kappa maki, avocado maki, maguro maki ,chuka salad – 1800/150/100/60g 59 buc.	900.00	https://ohmysushi.md/wp-content/uploads/2024/09/f79df468b57248088afa735226efc49434d5b63153c06b8bcd470e3cbbf80fa5-247x247.jpg	1	2025-04-04 12:49:26.369683	2025-04-04 12:49:26.369683	f	900.00	900.00
13	Bonito ebi	Fulgi de ton, avocado, tobiko, philadelphia cream, creveți – 280/50/25/15 g.	185.00	https://ohmysushi.md/wp-content/uploads/2024/09/9b2e3ea8b1829e30ad0a90fe0dc1f4e748e61663cb3961a657b0ca4e3e66926d-247x247.jpg	2	2025-04-04 12:49:30.447305	2025-04-04 12:49:30.447305	f	185.00	185.00
14	Bonito sake	Fulgi de ton, philadelphia cream, castraveți, somon, tobiko – 280/50/25/15 g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/bf6e444b8fcfcdf358b7d872ecd533519e3f25a7e501ce202224cf17df5ae109-247x247.jpg	2	2025-04-04 12:49:32.143225	2025-04-04 12:49:32.143225	f	180.00	180.00
4	Events set	Philadelphia, California black & white, Imperator, Kani tempura, Kani hot vulkan, Sake maki – 1600/150/75/60 g, 48 buc	800.00	https://ohmysushi.md/wp-content/uploads/2024/09/b20c45e9262cfe8d508c5aef48801ac044288d3ede5e3a58ec474a8d88a6f0c4-247x247.jpg	1	2025-04-04 12:49:12.270089	2025-04-04 12:49:12.270089	f	800.00	800.00
6	Oh! My sushi set	Sake tempura, maguro tempura, kani tempura, california classic, canada, green dragon, brunt sake, hadaka sake, hadaka maguro, kappa maki, avocado maki, maguro maki, nigiri sake, nigiri ebi, nigiri maguro, chuka salad – 3250/250/150/100g 91buc	1500.00	https://ohmysushi.md/wp-content/uploads/2024/09/30553b43fa0f61cc11996dbabd0f8239ad845d85061d9d94047bfbc9a8131b47-247x247.jpg	1	2025-04-04 12:49:15.721911	2025-04-04 12:49:15.721911	f	1500.00	1500.00
7	Oh! My super sushi set	Golden dragon, sake dragon, green dragon, maguro dragon, alaska, Philadelphia duble cheese, maguro roll, hadaka sake, hadaka ebi, avocado maki, sake maki, kappa maki, maguro maki, ebi maki, tobiko cheese maki – 3.500/300/200/150g 120buc	1850.00	https://ohmysushi.md/wp-content/uploads/2024/09/d4eccd-247x247.jpg	1	2025-04-04 12:49:17.465369	2025-04-04 12:49:17.465369	f	1850.00	1850.00
8	Otomo sushi set	Kani tempura, maguro maki, chuka domino.	290.00	https://ohmysushi.md/wp-content/uploads/2024/12/img_8129-247x247.jpeg	1	2025-04-04 12:49:19.211366	2025-04-04 12:49:19.211366	t	580.00	290.00
9	Party set	Philadelphia, California, California black & white, Ebi tempura, Sake maki – 1270/90/45/30 g, 40 buc	700.00	https://ohmysushi.md/wp-content/uploads/2024/09/04265a740e461a3601150e708471198e36b8b1407e0a3b38b085469acbb084de-247x247.jpg	1	2025-04-04 12:49:21.046527	2025-04-04 12:49:21.046527	f	700.00	700.00
15	Burn cheese	Cedar, philadelphia cream, castraveți, somon prăjit, sos spicy, gemeni de verdeață – 300/50/25/15 g.	175.00	https://ohmysushi.md/wp-content/uploads/2024/09/3142e79214506c5431ba34792031acb3d2aea392349b22413dbc0b6b07f58804-247x247.jpg	2	2025-04-04 12:49:33.85679	2025-04-04 12:49:33.85679	f	175.00	175.00
16	Burn sake	Somon grill, philadelphia cream, castraveți, avocado, crevete, sos spicy, gemeni de verdeață – 300/50/25/15 g.	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/329df6e196819c96cf2f22b0172405eac21147c8fb735bdd5d872e4b77d57706-247x247.jpg	2	2025-04-04 12:49:35.551681	2025-04-04 12:49:35.551681	f	195.00	195.00
17	California classic	Tobico, creveți, avocado, maioneză japoneza – 280/50/25/15 g.	190.00	https://ohmysushi.md/wp-content/uploads/2024/09/2c9ea4cdce00013b5af6c9e816cd6a108856ded12fba8f809b2e09373811563d-247x247.jpg	2	2025-04-04 12:49:37.25137	2025-04-04 12:49:37.25137	f	190.00	190.00
18	California kani white	Crab snow, susan alb, castraveți, avocado, cremette – 280/50/25/15 g.	165.00	https://ohmysushi.md/wp-content/uploads/2024/09/d59383dd1a7362846702cb6d2e5c361d2c91c7c92e4d42124016e3af53ffb57e-247x247.jpg	2	2025-04-04 12:49:38.972156	2025-04-04 12:49:38.972156	f	165.00	165.00
19	California maguro black	Tobico, ton, castraveți, avocado, cremette. – 280/50/25/15 g.	190.00	https://ohmysushi.md/wp-content/uploads/2024/09/77a05af1f23956b5603b76091bebdbf088a0761da09f9768a14b0802efa906ee-247x247.jpg	2	2025-04-04 12:49:40.702428	2025-04-04 12:49:40.702428	f	190.00	190.00
20	California sake	Tobiko, castraveți, avocado, somon, cremette – 280/50/25/15 g.	175.00	https://ohmysushi.md/wp-content/uploads/2024/09/32534ab595cb6d59b0e5a0b1bd4043175b9142db9d56c81e5c99807db9fa3dd0-247x247.jpg	2	2025-04-04 12:49:42.39469	2025-04-04 12:49:42.39469	f	175.00	175.00
21	California unagi	Susan, țipar, avocado, castraveți, philadelphia cream, sos unagi – 280/50/25/15g.	170.00	https://ohmysushi.md/wp-content/uploads/2024/09/11c73cb59448c6d844f8abfb1ea32720195b1ba9f3956db37d55c4f11046067e-247x247.jpg	2	2025-04-04 12:49:44.198808	2025-04-04 12:49:44.198808	f	170.00	170.00
22	Canada	Țipar, avocado, somon, philadelphia cream, susan, sos unagi – 280/50/25/15 g.	200.00	https://ohmysushi.md/wp-content/uploads/2024/09/3a776c82f6924d231e8af9a9ec9933b1399b5478434c6e440cc5c697b3c902d2-247x247.jpg	2	2025-04-04 12:49:45.909504	2025-04-04 12:49:45.909504	f	200.00	200.00
23	Chuka ebi	Chuka, creveți, avocado, philadelphia cream, susan – 300/50/25/15 g.	185.00	https://ohmysushi.md/wp-content/uploads/2024/09/32da301d1b375644f7c8497bc2c99c27e2fb42d5b41c03532f1f201d64c089a3-247x247.jpg	2	2025-04-04 12:49:47.675135	2025-04-04 12:49:47.675135	f	185.00	185.00
24	Chuka sake	Chuka, somon, castraveți, mango, susan, philadelphia cream – 300/50/25/15 g.	180.00	https://ohmysushi.md/wp-content/uploads/2024/09/5e0b6c5d4c6a4e88ec51aa5b0a405b283d856f529d602565d81513e8e6bcb4a9-247x247.jpg	2	2025-04-04 12:49:49.420417	2025-04-04 12:49:49.420417	f	180.00	180.00
25	Avocado Maki	Avocado, orez, nori, susan, vasabi, ghimbir, sos de soia – 140/50/25/15g	65.00	https://ohmysushi.md/wp-content/uploads/2024/09/Avocado-Maki-247x247.jpeg	3	2025-04-04 12:49:53.316697	2025-04-04 12:49:53.316697	f	65.00	65.00
118	Tobico Maki	Tobico, philadelphia cream, susan, orez, nori, vasabi, ghimbir, sos de soia – 140/50/25/15 g	95.00	https://ohmysushi.md/wp-content/uploads/2024/09/Tobico-Maki-247x247.jpeg	3	2025-04-04 14:09:05.654387	2025-04-04 14:09:05.654387	f	95.00	95.00
119	Unagi Maki	Țipar, orez, susan, nori, unagi, vasabi, ghimbir, sos soia – 140/50/25/15 g.	90.00	https://ohmysushi.md/wp-content/uploads/2024/09/Unagi-Maki-247x247.jpeg	3	2025-04-04 14:09:07.386552	2025-04-04 14:09:07.386552	f	90.00	90.00
121	Ton Tataki	Ton, susan, ulei de floarea soarelui, mix de verdeță, roșii cherry, sos unagi – 150/100g	195.00	https://ohmysushi.md/wp-content/uploads/2024/09/Ton-Tataki-247x247.jpeg	7	2025-04-04 14:09:30.516651	2025-04-04 14:09:30.516651	f	195.00	195.00
122	Udon Beef	Mușchi de vită, morcov, ardei, ciuperci, bostănel, susan, sos thai, udon, germeni de plante – 370g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Udon-Beef-247x247.jpeg	7	2025-04-04 14:09:32.263702	2025-04-04 14:09:32.263702	f	145.00	145.00
123	Udon Chicken	Udon, carne de pui, ardei california, ciuperci, morcov, bostănel, sos thai, susan, germeni de ceapă – 370g	100.00	https://ohmysushi.md/wp-content/uploads/2024/09/Udon-Chicken-247x247.jpeg	7	2025-04-04 14:09:34.010614	2025-04-04 14:09:34.010614	f	100.00	100.00
124	Udon Duck	Fileu de rață, ardei california, ciuperci, morcov, bostanel, susan, sos thai, udon, sos tiriyaki, germeni de ceapă – 370g	145.00	https://ohmysushi.md/wp-content/uploads/2024/09/Udon-Duck-247x247.jpeg	7	2025-04-04 14:09:35.746618	2025-04-04 14:09:35.746618	f	145.00	145.00
125	Udon Oceania	Coctail fructe de mare, morcov, bostănel, ciuperci, ardei california, sos thai, susan, udon, germeni de ceapă – 370g	160.00	https://ohmysushi.md/wp-content/uploads/2024/09/Udon-Oceania-247x247.jpeg	7	2025-04-04 14:09:37.596951	2025-04-04 14:09:37.596951	f	160.00	160.00
127	Green Detox Smoothie	Green Detox Smoothie	38.00	https://ohmysushi.md/wp-content/uploads/2025/01/img_8715-247x247.jpeg	9	2025-04-04 14:09:51.843445	2025-04-04 14:09:51.843445	f	38.00	38.00
128	Schweppes Mojito	330ml	18.00	https://ohmysushi.md/wp-content/uploads/2024/11/9-247x247.png	9	2025-04-04 14:09:53.546581	2025-04-04 14:09:53.546581	f	18.00	18.00
129	Schweppes Pomegranate	330ml	18.00	https://ohmysushi.md/wp-content/uploads/2024/11/10-247x247.png	9	2025-04-04 14:09:55.289992	2025-04-04 14:09:55.289992	f	18.00	18.00
130	Sprite	500ml	22.00	https://ohmysushi.md/wp-content/uploads/2024/11/5-247x247.png	9	2025-04-04 14:09:56.997477	2025-04-04 14:09:56.997477	f	22.00	22.00
89	Otomo sushi set	Kani tempura, maguro maki, chuka domino	290.00	https://ohmysushi.md/wp-content/uploads/2024/12/img_8129-247x247.jpeg	1	2025-04-04 14:07:48.529337	2025-04-04 14:07:48.529337	t	580.00	290.00
120	Black Pepper Steak	Mușchi de vită, mix de salată, roșii chery, susan, sos black pepper – 200/100g	250.00	https://ohmysushi.md/wp-content/uploads/2024/09/Steak-De-Vita-In-Sos-Black-Pepper-247x247.jpeg	7	2025-04-04 14:09:28.786266	2025-04-04 14:09:28.786266	f	250.00	250.00
126	Vegetable Rice	Orez,morcov,ardei,ciuperci,bostănel,susan,sos thai,germeni de ceapă - 370g	90.00	https://ohmysushi.md/wp-content/uploads/2024/09/Vegetable-Rice-247x247.jpeg	7	2025-04-04 14:09:39.334769	2025-04-04 14:09:39.334769	f	90.00	90.00
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.schema_migrations (version) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: ivan
--

COPY public.users (id, telegram_id, first_name, last_name, username, language, created_at, updated_at) FROM stdin;
1	444940427	Ivan	Teaca	\N	ru	2025-04-04 07:59:01.540431	2025-04-04 07:59:01.540431
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ivan
--

SELECT pg_catalog.setval('public.categories_id_seq', 11, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ivan
--

SELECT pg_catalog.setval('public.order_items_id_seq', 7, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ivan
--

SELECT pg_catalog.setval('public.orders_id_seq', 2, true);


--
-- Name: product_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ivan
--

SELECT pg_catalog.setval('public.product_categories_id_seq', 25, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ivan
--

SELECT pg_catalog.setval('public.products_id_seq', 130, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ivan
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_order_items_on_order_id; Type: INDEX; Schema: public; Owner: ivan
--

CREATE INDEX index_order_items_on_order_id ON public.order_items USING btree (order_id);


--
-- Name: index_order_items_on_product_id; Type: INDEX; Schema: public; Owner: ivan
--

CREATE INDEX index_order_items_on_product_id ON public.order_items USING btree (product_id);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: ivan
--

CREATE INDEX index_orders_on_user_id ON public.orders USING btree (user_id);


--
-- Name: index_product_categories_on_category_id; Type: INDEX; Schema: public; Owner: ivan
--

CREATE INDEX index_product_categories_on_category_id ON public.product_categories USING btree (category_id);


--
-- Name: index_product_categories_on_product_id; Type: INDEX; Schema: public; Owner: ivan
--

CREATE INDEX index_product_categories_on_product_id ON public.product_categories USING btree (product_id);


--
-- Name: index_products_on_category_id; Type: INDEX; Schema: public; Owner: ivan
--

CREATE INDEX index_products_on_category_id ON public.products USING btree (category_id);


--
-- Name: products fk_rails_fb915499a4; Type: FK CONSTRAINT; Schema: public; Owner: ivan
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_rails_fb915499a4 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- PostgreSQL database dump complete
--

