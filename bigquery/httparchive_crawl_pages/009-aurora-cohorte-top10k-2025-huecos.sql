-- Fecha: 2026-10-14
-- Propósito: completar la custom metric "aurora" de 2025 donde 006 y 007 no llegan (mismas columnas).
--            (1) los 176 sitios de la cohorte de escritorio (rank <= 10000 en el crawl de
--            escritorio de ene-2025) que no están en la lista móvil de 006/007: rank <= 50000, los 12 meses;
--            (2) los 3634 sitio-mes observados en el panel (cross_source/007 y 008) con rank > 50000, cada
--            uno con su mes, cliente y rank (ej. id.soccerway.com, rank 100000 en jul y 500000 en ago-dic).
-- Filtro de partición: date BETWEEN '2025-01-01' AND '2025-12-01' + is_root_page + una condición por
--            mes, cliente y rank con su lista literal de páginas (126 condiciones unidas por OR;
--            rank y page son columnas de clustering, el dry-run no lo refleja)
-- Tablas: httparchive.crawl.pages

SELECT
  date,
  client,
  page,
  rank,
  JSON_VALUE(custom_metrics.other, '$.aurora.react_version')    AS aurora_react,
  JSON_VALUE(custom_metrics.other, '$.aurora.next_version')     AS aurora_next,
  JSON_VALUE(custom_metrics.other, '$.aurora.nuxt_version')     AS aurora_nuxt,
  JSON_VALUE(custom_metrics.other, '$.aurora.nuxt_vue_version') AS aurora_nuxt_vue,
  JSON_VALUE(custom_metrics.other, '$.aurora.ng_version')       AS aurora_angular,
  JSON_VALUE(custom_metrics.other, '$.aurora.svelte_version')   AS aurora_svelte,
  ARRAY_LENGTH(technologies)                                    AS n_tecnologias_wappalyzer
FROM `httparchive.crawl.pages`
WHERE date BETWEEN '2025-01-01' AND '2025-12-01'
  AND is_root_page
  AND (
    (client = 'desktop' AND rank <= 50000 AND page IN (
      'https://999.md/', 'https://agwl2.idnpaito.com/', 'https://agwl2.suksesbogil.com/', 'https://agwl3.suksesbogil.com/',
      'https://agwl7.suksesbogil.com/', 'https://andpad.jp/', 'https://app-eu1.hubspot.com/', 'https://app.agencybloc.com/',
      'https://app.hubspot.com/', 'https://app.slack.com/', 'https://apps.dmac-solutions.net/', 'https://asd.quest/',
      'https://bbs.ruliweb.com/', 'https://bigpara.hurriyet.com.tr/', 'https://bk.augipt.com/', 'https://blocked.syd-1.linewize.net/',
      'https://br.shein.com/', 'https://bulbapedia.bulbagarden.net/', 'https://canvas.apps.chrome/', 'https://chzzk.naver.com/',
      'https://comic.naver.com/', 'https://commons.wikimedia.org/', 'https://conjuguemos.com/', 'https://de.wikipedia.org/',
      'https://emaktab.uz/', 'https://en.wikipedia.org/', 'https://es-la.facebook.com/', 'https://es.shein.com/',
      'https://es.wikipedia.org/', 'https://estama.jp/', 'https://fconline.nexon.com/', 'https://finance.naver.com/',
      'https://forum.gamer.com.tw/', 'https://fr.shein.com/', 'https://fr.wikipedia.org/', 'https://gall.dcinside.com/',
      'https://heovl.plus/', 'https://hqporner.com/', 'https://ibpj.sicredi.com.br/', 'https://it.wikipedia.org/',
      'https://item.taobao.com/', 'https://ja.wikipedia.org/', 'https://kabutan.jp/', 'https://kakaku.com/',
      'https://kenh14.vn/', 'https://land.naver.com/', 'https://live.bilibili.com/', 'https://live.nicovideo.jp/',
      'https://loigiaihay.com/', 'https://mail.yahoo.com/', 'https://manga.nicovideo.jp/', 'https://manowar.hover.to/',
      'https://map.naver.com/', 'https://maplestory.nexon.com/', 'https://math.imaginelearning.com/', 'https://metruyencv.com/',
      'https://mlsbd.shop/', 'https://my.mheducation.com/', 'https://news.nate.com/', 'https://nl.wikipedia.org/',
      'https://nortonsafe.search.ask.com/', 'https://ok.ru/', 'https://ondisk.co.kr/', 'https://pancake.vn/',
      'https://pe.search.yahoo.com/', 'https://pl.wikipedia.org/', 'https://pm.eyefinity.com/', 'https://poe2.game.daum.net/',
      'https://pro.housecallpro.com/', 'https://pt.wikipedia.org/', 'https://race.netkeiba.com/', 'https://rakuten.dropgame.jp/',
      'https://read.amazon.co.jp/', 'https://roundrockisd.schoology.com/', 'https://ru.wikipedia.org/', 'https://search-sprint.com/',
      'https://search.bilibili.com/', 'https://search.vivastreet.co.uk/', 'https://seller.indiamart.com/', 'https://sellercenter.lazada.co.th/',
      'https://soundcloud.com/', 'https://sports.news.naver.com/', 'https://subscriptions.teachtci.com/', 'https://suchen.mobile.de/',
      'https://sushida.net/', 'https://t.bilibili.com/', 'https://tabelog.com/', 'https://testing.illuminateed.com/',
      'https://thuvienphapluat.vn/', 'https://tr.wikipedia.org/', 'https://typingerz.com/', 'https://us.shein.com/',
      'https://vi.wikipedia.org/', 'https://vk.com/', 'https://vkvideo.ru/', 'https://vlxx.film/',
      'https://vn.search.yahoo.com/', 'https://web.facebook.com/', 'https://web.humoruniv.com/', 'https://weibo.com/',
      'https://www.11st.co.kr/', 'https://www.17track.net/', 'https://www.abcya.com/', 'https://www.alza.cz/',
      'https://www.alza.sk/', 'https://www.ancestry.co.uk/', 'https://www.aocrecruitment.gov.in/', 'https://www.avito.ru/',
      'https://www.bild.de/', 'https://www.bilibili.com/', 'https://www.bobaedream.co.kr/', 'https://www.brainpop.com/',
      'https://www.canalrcn.com/', 'https://www.cda.pl/', 'https://www.coupang.com/', 'https://www.courts.mo.gov/',
      'https://www.cricbuzz.com/', 'https://www.daum.net/', 'https://www.douban.com/', 'https://www.expedia.com/',
      'https://www.fabguys.com/', 'https://www.fabswingers.com/', 'https://www.facebook.com/', 'https://www.filmaffinity.com/',
      'https://www.fmkorea.com/', 'https://www.focus.de/', 'https://www.getepic.com/', 'https://www.gimkit.com/',
      'https://www.gsmarena.com/', 'https://www.hoodamath.com/', 'https://www.ilbe.com/', 'https://www.imdb.com/',
      'https://www.instiz.net/', 'https://www.inven.co.kr/', 'https://www.ixl.com/', 'https://www.jobkorea.co.kr/',
      'https://www.kidsa-z.com/', 'https://www.manhuagui.com/', 'https://www.mobile01.com/', 'https://www.momoshop.com.tw/',
      'https://www.naver.com/', 'https://www.nicovideo.jp/', 'https://www.nieuwsblad.be/', 'https://www.noredink.com/',
      'https://www.office.com/', 'https://www.olx.pl/', 'https://www.olx.ua/', 'https://www.openwork.jp/',
      'https://www.partslink24.com/', 'https://www.posta.com.tr/', 'https://www.ppomppu.co.kr/', 'https://www.quill.org/',
      'https://www.saramin.co.kr/', 'https://www.slrclub.com/', 'https://www.sooplive.co.kr/', 'https://www.southwest.com/',
      'https://www.sports.ru/', 'https://www.ss.com/', 'https://www.ss.lv/', 'https://www.starfall.com/',
      'https://www.startlap.hu/', 'https://www.tagged.com/', 'https://www.trojmiasto.pl/', 'https://www.twitch.tv/',
      'https://www.usaa.com/', 'https://www.vrbo.com/', 'https://www.wcostream.tv/', 'https://www.webnovel.com/',
      'https://www.webtoons.com/', 'https://www.yahoo.co.jp/', 'https://www.yelp.com/', 'https://www.youtube.com/',
      'https://www.zearn.org/', 'https://www3.animeflv.net/', 'https://ygosu.com/', 'https://zh.wikipedia.org/'))
    OR (date = '2025-02-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://cejoapsoo.net/', 'https://dti.mendoza.edu.ar/', 'https://mall.bookcapital.com.my/', 'https://nashickaltirdab.com/',
      'https://rogmovies.fun/', 'https://school.banglarshiksha.gov.in/', 'https://seges.sedu.es.gov.br/', 'https://sor-soch.com/',
      'https://ukpppg.bppp.kemdikbud.go.id/', 'https://vdpro.jp/', 'https://wrapup.playstation.com/', 'https://www.becaritacetina.gob.mx/',
      'https://www.canalrcn.com/', 'https://www.drawnames.com/', 'https://www.plus.fifa.com/', 'https://www.starbucksforlife.com/',
      'https://www.swisscolony.com/', 'https://www.xvcams.com/'))
    OR (date = '2025-02-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'https://adventofcode.com/', 'https://aiveemtomsaix.net/', 'https://blaze.com/', 'https://csirnetdec2024.ntaonline.in/',
      'https://decomytree.com/', 'https://drawnames.app/', 'https://fantasy.nfl.com/', 'https://gsa.teletalk.com.bd/',
      'https://icai.nic.in/', 'https://kr72.sogirl.so/', 'https://sexmex.top/', 'https://superbet.com/',
      'https://ujian.unnes.ac.id/', 'https://wfwf364.com/', 'https://www.amigosecreto.com.br/', 'https://www.elfster.com/',
      'https://www.portablenorthpole.com/', 'https://www.prcboard.com/', 'https://www.prokabaddi.com/'))
    OR (date = '2025-02-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://m.gameshop4u.com/', 'https://nakarmpsa.olx.pl/', 'https://toahicobeerile.com/', 'https://wfwf363.com/',
      'https://www.noradsanta.org/'))
    OR (date = '2025-02-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://broadensilkslush.com/', 'https://goboksehee.net/', 'https://greerogloo.net/', 'https://wfwf360.com/',
      'https://wfwf361.com/', 'https://wfwf362.com/'))
    OR (date = '2025-02-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://312bet2.com/', 'https://54bet4.com/', 'https://alexisanemo.com/', 'https://bet30.click/',
      'https://botdrivea.filesdl.in/', 'https://cejoapsoo.net/', 'https://celuapuestas.io/', 'https://desipapa.watch/',
      'https://dti.mendoza.edu.ar/', 'https://home89311.com/', 'https://m.porno666.men/', 'https://mall.bookcapital.com.my/',
      'https://my-wishes.co/', 'https://mycard10.com/', 'https://nashickaltirdab.com/', 'https://on82552.com/',
      'https://pro87112.com/', 'https://rogmovies.fun/', 'https://school.banglarshiksha.gov.in/', 'https://seges.sedu.es.gov.br/',
      'https://sor-soch.com/', 'https://sugaroy.com/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://vdpro.jp/',
      'https://wanli.mja4nz.cc/', 'https://wrapup.playstation.com/', 'https://www.becaritacetina.gob.mx/', 'https://www.drawnames.com/',
      'https://www.newsnationtv.com/', 'https://www.plus.fifa.com/', 'https://www.seneporno.com/', 'https://www.starbucksforlife.com/',
      'https://www.swisscolony.com/', 'https://www.tbgameloader.com/', 'https://www.xvcams.com/'))
    OR (date = '2025-02-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'https://adventofcode.com/', 'https://aiveemtomsaix.net/', 'https://chromeos.dev/', 'https://community.truecaller.com/',
      'https://csirnetdec2024.ntaonline.in/', 'https://decomytree.com/', 'https://doralotto.com/', 'https://doralotto.land/',
      'https://drawnames.app/', 'https://expresswish.co/', 'https://fantasy.nfl.com/', 'https://geng39652.com/',
      'https://gsa.teletalk.com.bd/', 'https://hondagalaxy.com/', 'https://icai.nic.in/', 'https://indiawishes.co/',
      'https://indviral.com/', 'https://jenepontooh.com/', 'https://kr72.sogirl.so/', 'https://m.new8815.cc/',
      'https://ratukediri.com/', 'https://sexmex.top/', 'https://siswa.pijarsekolah.id/', 'https://superbet.com/',
      'https://ujian.unnes.ac.id/', 'https://upsos.in/', 'https://wfwf364.com/', 'https://win.in-pari-match.com/',
      'https://winalto.org/', 'https://www.54bet1.com/', 'https://www.amigosecreto.com.br/', 'https://www.elfster.com/',
      'https://www.myjobalarm.com/', 'https://www.portablenorthpole.com/', 'https://www.prcboard.com/', 'https://www.prokabaddi.com/'))
    OR (date = '2025-02-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://bewhoopoalso.com/', 'https://buvaulsamoapte.com/', 'https://kairustaubu.com/', 'https://m.gameshop4u.com/',
      'https://nakarmpsa.olx.pl/', 'https://toahicobeerile.com/', 'https://wfwf363.com/', 'https://www.noradsanta.org/'))
    OR (date = '2025-02-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://alexisayaka.com/', 'https://avd.grapevine.uk.com/', 'https://broadensilkslush.com/', 'https://goboksehee.net/',
      'https://greerogloo.net/', 'https://mawarkece.com/', 'https://mawartoto3079.com/', 'https://technicalranjay.co/',
      'https://wfwf360.com/', 'https://wfwf361.com/', 'https://wfwf362.com/'))
    OR (date = '2025-02-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://mawargokil.com/', 'https://mawarwangi.com/'))
    OR (date = '2025-03-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://ak.ptailadsol.net/', 'https://celebrityjest.com/', 'https://cryptonews-24.com/', 'https://ctet.nic.in/',
      'https://forexpipinsight.com/', 'https://free.apkzonic.com/', 'https://login.rosettastone.com/', 'https://lokapai.ppgkemenag.com/',
      'https://motoratrium.com/', 'https://numberticket.jp/', 'https://point-g.rakuten.co.jp/', 'https://santatracker.google.com/',
      'https://school.banglarshiksha.gov.in/', 'https://sistemas.educacao.ma.gov.br/', 'https://thisav.com/', 'https://vdpro.jp/',
      'https://w4nkr.com/', 'https://www.drawnames.com/', 'https://www.esic.in/', 'https://www.fantasypros.com/',
      'https://www.picuki.com/', 'https://www.plus.fifa.com/', 'https://www.prcboard.com/', 'https://www.snitch.co.in/',
      'https://www.swisscolony.com/', 'https://www.xvcams.com/', 'https://zrelki.link/'))
    OR (date = '2025-03-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'https://adventofcode.com/', 'https://babynombres.com/', 'https://cejoapsoo.net/', 'https://drawnames.app/',
      'https://ferromotor.com/', 'https://football.fantasysports.yahoo.com/', 'https://footballforge.com/', 'https://icai.nic.in/',
      'https://linkintime.co.in/', 'https://lms.tnsed.com/', 'https://mall.bookcapital.com.my/', 'https://nashickaltirdab.com/',
      'https://play31.808ball.com/', 'https://play31.808fubo.com/', 'https://ris.kfintech.com/', 'https://rogmovies.fun/',
      'https://ujian.unnes.ac.id/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://voguefashionvibe.com/', 'https://www.elfster.com/',
      'https://www.portablenorthpole.com/', 'https://www.prokabaddi.com/'))
    OR (date = '2025-03-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://blaze.com/', 'https://decomytree.com/', 'https://fantasy.nfl.com/', 'https://gsa.teletalk.com.bd/',
      'https://kr72.sogirl.so/', 'https://sexmex.top/', 'https://superbet.com/', 'https://tamilglitz.in/',
      'https://wechoice.vn/', 'https://wrapup.playstation.com/', 'https://www.amigosecreto.com.br/'))
    OR (date = '2025-03-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://aiveemtomsaix.net/', 'https://dtruyen.net/', 'https://goboksehee.net/', 'https://m.gameshop4u.com/',
      'https://nakarmpsa.olx.pl/', 'https://truyenfull.tv/', 'https://wfwf360.com/', 'https://wfwf361.com/',
      'https://wfwf362.com/', 'https://wfwf363.com/', 'https://wfwf364.com/', 'https://www.noradsanta.org/',
      'https://www.starbucksforlife.com/'))
    OR (date = '2025-03-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://broadensilkslush.com/', 'https://gameshelion.com/'))
    OR (date = '2025-03-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://ak.ptailadsol.net/', 'https://anchorit.live/', 'https://bet30.click/', 'https://celebrityjest.com/',
      'https://celuapuestas.io/', 'https://community.truecaller.com/', 'https://cryptonews-24.com/', 'https://ctet.nic.in/',
      'https://forexpipinsight.com/', 'https://free.apkzonic.com/', 'https://login.rosettastone.com/', 'https://lokapai.ppgkemenag.com/',
      'https://motoratrium.com/', 'https://movies.downloadmv.site/', 'https://numberticket.jp/', 'https://point-g.rakuten.co.jp/',
      'https://santatracker.google.com/', 'https://school.banglarshiksha.gov.in/', 'https://sistemas.educacao.ma.gov.br/', 'https://thisav.com/',
      'https://vdpro.jp/', 'https://w4nkr.com/', 'https://www.drawnames.com/', 'https://www.esic.in/',
      'https://www.fantasypros.com/', 'https://www.picuki.com/', 'https://www.playinexchange.com/', 'https://www.plus.fifa.com/',
      'https://www.prcboard.com/', 'https://www.snitch.co.in/', 'https://www.swisscolony.com/', 'https://www.tbgameloader.com/',
      'https://www.xvcams.com/', 'https://zia82522.com/', 'https://zrelki.link/'))
    OR (date = '2025-03-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'https://312bet2.com/', 'https://54bet4.com/', 'https://abutogelcerdas.com/', 'https://adventofcode.com/',
      'https://api.firstpaym.com/', 'https://babynombres.com/', 'https://botdrivea.filesdl.in/', 'https://cejoapsoo.net/',
      'https://chromeos.dev/', 'https://desipapa.watch/', 'https://drawnames.app/', 'https://ferromotor.com/',
      'https://football.fantasysports.yahoo.com/', 'https://footballforge.com/', 'https://geng39652.com/', 'https://home89311.com/',
      'https://hondagalaxy.com/', 'https://icai.nic.in/', 'https://indviral.com/', 'https://jenepontooh.com/',
      'https://linkintime.co.in/', 'https://lms.tnsed.com/', 'https://luna89921.com/', 'https://m.24xxx.men/',
      'https://m.new8815.cc/', 'https://m.porno666.men/', 'https://mall.bookcapital.com.my/', 'https://me.yaeby.club/',
      'https://mycard10.com/', 'https://nashickaltirdab.com/', 'https://on82552.com/', 'https://parimatch1-aviator.com/',
      'https://play31.808ball.com/', 'https://play31.808fubo.com/', 'https://playbazaar.com/', 'https://pro87112.com/',
      'https://ratukediri.com/', 'https://ris.kfintech.com/', 'https://rogmovies.fun/', 'https://sugaroy.com/',
      'https://tamil.hindustantimes.com/', 'https://ujian.unnes.ac.id/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://voguefashionvibe.com/',
      'https://web.ayoba.me/', 'https://win.in-pari-match.com/', 'https://winbuzz.games/', 'https://www.54bet1.com/',
      'https://www.bayburtpostasi.com.tr/', 'https://www.elfster.com/', 'https://www.newsnationtv.com/', 'https://www.portablenorthpole.com/',
      'https://www.prokabaddi.com/'))
    OR (date = '2025-03-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://collegeofeducation.org/', 'https://decomytree.com/', 'https://fantasy.nfl.com/', 'https://gsa.teletalk.com.bd/',
      'https://indiawishes.co/', 'https://kr72.sogirl.so/', 'https://mt1.89k.app/', 'https://ru.fap-guru.fun/',
      'https://sexmex.top/', 'https://superbet.com/', 'https://tamilglitz.in/', 'https://wechoice.vn/',
      'https://wrapup.playstation.com/', 'https://www.amigosecreto.com.br/', 'https://www.myjobalarm.com/'))
    OR (date = '2025-03-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://aiveemtomsaix.net/', 'https://alexisayaka.com/', 'https://damangame.chat/', 'https://dlscollege.com/',
      'https://doralotto.com/', 'https://doralotto.org/', 'https://dtruyen.net/', 'https://expresswish.co/',
      'https://goboksehee.net/', 'https://greerogloo.net/', 'https://m.gameshop4u.com/', 'https://mawarwangi.com/',
      'https://mtg.89k.app/', 'https://nakarmpsa.olx.pl/', 'https://tarifatransacionalhoje.com/', 'https://technicalranjay.co/',
      'https://truyenfull.tv/', 'https://upsos.in/', 'https://wfwf360.com/', 'https://wfwf361.com/',
      'https://wfwf362.com/', 'https://wfwf363.com/', 'https://wfwf364.com/', 'https://www.alanyahaber.com/',
      'https://www.noradsanta.org/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-03-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://broadensilkslush.com/', 'https://filmjepang.viralterbaru.wiki/', 'https://gameshelion.com/', 'https://mawargokil.com/',
      'https://mawarkece.com/', 'https://mawartoto3079.com/', 'https://nombresdetubaby.com/', 'https://osateching.com/',
      'https://sombracycling.com/', 'https://tannyfashion.com/', 'https://wanli.mja4nz.cc/', 'https://winalto.org/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://ak.ptailadsol.net/', 'https://contoseroticoscnn.com/', 'https://csirnetdec2024.ntaonline.in/', 'https://da88.win/',
      'https://epaddy.wb.gov.in/', 'https://free.apkzonic.com/', 'https://ipowatch.in/', 'https://login.rosettastone.com/',
      'https://mangamammy.ru/', 'https://numberticket.jp/', 'https://paspor-gtk.simpkb.id/', 'https://pathofexile2.com/',
      'https://santatracker.google.com/', 'https://school.banglarshiksha.gov.in/', 'https://store.ankama.com/', 'https://ugcnet.nta.ac.in/',
      'https://vdpro.jp/', 'https://www.aocrecruitment.gov.in/', 'https://www.esic.in/', 'https://www.picuki.com/',
      'https://www.porn69.net/', 'https://www.snitch.co.in/', 'https://www.swisscolony.com/', 'https://www.vendeeglobe.org/',
      'https://www.xvcams.com/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'https://adventofcode.com/', 'https://ak.naiwoalooca.net/', 'https://aov-news.com/', 'https://azmip.com/',
      'https://celebrityjest.com/', 'https://football.fantasysports.yahoo.com/', 'https://footballforge.com/', 'https://forexpipinsight.com/',
      'https://mall.bookcapital.com.my/', 'https://nashickaltirdab.com/', 'https://play31.808ball.com/', 'https://play31.808fubo.com/',
      'https://point-g.rakuten.co.jp/', 'https://ris.kfintech.com/', 'https://sistemas.educacao.ma.gov.br/', 'https://thisav.com/',
      'https://ugcnetdec2024.ntaonline.in/', 'https://ujian.unnes.ac.id/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://vip.rusvideos.day/',
      'https://voguefashionvibe.com/', 'https://w4nkr.com/', 'https://whoucheehy.net/', 'https://www.amigosecreto.com.br/',
      'https://www.dailynayadiganta.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/', 'https://www.portablenorthpole.com/',
      'https://www.prokabaddi.com/', 'https://zrelki.link/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://biwipuque.com/', 'https://cejoapsoo.net/', 'https://drawnames.app/', 'https://fantasy.nfl.com/',
      'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://nabauxou.net/', 'https://sexmex.top/',
      'https://wechoice.vn/', 'https://whoagnukrin.com/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'http://webserver1.siiaa.siu.buap.mx/', 'https://aiveemtomsaix.net/', 'https://babynombres.com/', 'https://decomytree.com/',
      'https://dtruyen.net/', 'https://firhub69.com/', 'https://greerogloo.net/', 'https://gsa.teletalk.com.bd/',
      'https://linkintime.co.in/', 'https://manganato.com/', 'https://motoratrium.com/', 'https://nakarmpsa.olx.pl/',
      'https://pelotainvernal.com/', 'https://rogmovies.fun/', 'https://superbet.com/', 'https://tamilglitz.in/',
      'https://truyenfull.tv/', 'https://wfwf360.com/', 'https://wfwf361.com/', 'https://wfwf362.com/',
      'https://wfwf363.com/', 'https://wfwf364.com/', 'https://wrapup.playstation.com/', 'https://www.noradsanta.org/',
      'https://www.starbucksforlife.com/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://broadensilkslush.com/', 'https://cryptonews-24.com/', 'https://goboksehee.net/', 'https://m.gameshop4u.com/',
      'https://pip.kemdikbud.go.id/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://ak.ptailadsol.net/', 'https://blogherald.com/', 'https://contoseroticoscnn.com/', 'https://csirnetdec2024.ntaonline.in/',
      'https://da88.win/', 'https://download.vidshare.site/', 'https://epaddy.wb.gov.in/', 'https://free.apkzonic.com/',
      'https://ipowatch.in/', 'https://login.rosettastone.com/', 'https://ludoplayers.com/', 'https://m.topaipick.com/',
      'https://mangamammy.ru/', 'https://numberticket.jp/', 'https://paspor-gtk.simpkb.id/', 'https://pathofexile2.com/',
      'https://reg.betway.co.za/', 'https://santatracker.google.com/', 'https://school.banglarshiksha.gov.in/', 'https://store.ankama.com/',
      'https://studycafe.in/', 'https://topushh.com/', 'https://ugcnet.nta.ac.in/', 'https://vdpro.jp/',
      'https://www.diggfun.co/', 'https://www.esic.in/', 'https://www.lagazzettadiviareggio.it/', 'https://www.parlons-basket.com/',
      'https://www.picuki.com/', 'https://www.playinexchange.com/', 'https://www.porn69.net/', 'https://www.snitch.co.in/',
      'https://www.swisscolony.com/', 'https://www.tbgameloader.com/', 'https://www.vendeeglobe.org/', 'https://www.xvcams.com/',
      'https://xxxcom.cam/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'https://312bet2.com/', 'https://54bet4.com/', 'https://abutogelcerdas.com/', 'https://adventofcode.com/',
      'https://ak.naiwoalooca.net/', 'https://aleqaria.com.eg/', 'https://aov-news.com/', 'https://api.firstpaym.com/',
      'https://azmip.com/', 'https://bokephit.com/', 'https://botdrivea.filesdl.in/', 'https://celebrityjest.com/',
      'https://chromeos.dev/', 'https://desipapa.watch/', 'https://football.fantasysports.yahoo.com/', 'https://footballforge.com/',
      'https://forexpipinsight.com/', 'https://gameshop.live/', 'https://geng39652.com/', 'https://goblinx.org/',
      'https://home89311.com/', 'https://hondagalaxy.com/', 'https://librecruitmentbirbhum.in/', 'https://luna89921.com/',
      'https://m.24xxx.men/', 'https://m.porno666.men/', 'https://mall.bookcapital.com.my/', 'https://me.yaeby.club/',
      'https://mlookelporno.com/', 'https://movies.downloadmv.site/', 'https://nanas39812.com/', 'https://nashickaltirdab.com/',
      'https://on82552.com/', 'https://play31.808ball.com/', 'https://play31.808fubo.com/', 'https://playbazaar.com/',
      'https://point-g.rakuten.co.jp/', 'https://pro87112.com/', 'https://progorod59.ru/', 'https://ratukediri.com/',
      'https://ris.kfintech.com/', 'https://sistemas.educacao.ma.gov.br/', 'https://sugaroy.com/', 'https://t.t789.bet/',
      'https://technicalranjay.net/', 'https://thisav.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://ujian.unnes.ac.id/',
      'https://ukpppg.bppp.kemdikbud.go.id/', 'https://uncutmaza.xyz/', 'https://ursextube.com/', 'https://vip.rusvideos.day/',
      'https://voguefashionvibe.com/', 'https://w4nkr.com/', 'https://web.ayoba.me/', 'https://whoucheehy.net/',
      'https://winbuzz.games/', 'https://www.54bet1.com/', 'https://www.amigosecreto.com.br/', 'https://www.bayburtpostasi.com.tr/',
      'https://www.dailynayadiganta.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/', 'https://www.expertsfaq.com/',
      'https://www.newsnationtv.com/', 'https://www.portablenorthpole.com/', 'https://www.prokabaddi.com/', 'https://zia82522.com/',
      'https://zrelki.link/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://biwipuque.com/', 'https://cejoapsoo.net/', 'https://drawnames.app/', 'https://fantasy.nfl.com/',
      'https://indviral.com/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://mycard10.com/',
      'https://nabauxou.net/', 'https://parimatch1-aviator.com/', 'https://ratemysoft.com/', 'https://ru.fap-guru.fun/',
      'https://sexmex.top/', 'https://wechoice.vn/', 'https://whoagnukrin.com/', 'https://win.in-pari-match.com/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'http://webserver1.siiaa.siu.buap.mx/', 'https://aiveemtomsaix.net/', 'https://alexisayaka.com/', 'https://babynombres.com/',
      'https://collegeofeducation.org/', 'https://damangame.chat/', 'https://decomytree.com/', 'https://dlscollege.com/',
      'https://doralotto.org/', 'https://dtruyen.net/', 'https://expresswish.co/', 'https://filmjepang.viralterbaru.wiki/',
      'https://firhub69.com/', 'https://greerogloo.net/', 'https://gsa.teletalk.com.bd/', 'https://indiawishes.co/',
      'https://linkintime.co.in/', 'https://manganato.com/', 'https://motoratrium.com/', 'https://mt1.89k.app/',
      'https://mtg.89k.app/', 'https://nakarmpsa.olx.pl/', 'https://pelotainvernal.com/', 'https://rogmovies.fun/',
      'https://sombracycling.com/', 'https://superbet.com/', 'https://tamilglitz.in/', 'https://technicalranjay.co/',
      'https://truyenfull.tv/', 'https://wfwf360.com/', 'https://wfwf361.com/', 'https://wfwf362.com/',
      'https://wfwf363.com/', 'https://wfwf364.com/', 'https://wrapup.playstation.com/', 'https://www.alanyahaber.com/',
      'https://www.myjobalarm.com/', 'https://www.noradsanta.org/', 'https://www.starbucksforlife.com/', 'https://www.wisesarees.com/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://broadensilkslush.com/', 'https://cryptonews-24.com/', 'https://doralotto.com/', 'https://ferromotor.com/',
      'https://gameshelion.com/', 'https://goboksehee.net/', 'https://m.gameshop4u.com/', 'https://nombresdetubaby.com/',
      'https://osateching.com/', 'https://pip.kemdikbud.go.id/', 'https://sports.vvffuuww22.com/', 'https://tannyfashion.com/',
      'https://tarifatransacionalhoje.com/', 'https://winalto.org/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://avd.grapevine.uk.com/', 'https://wanli.mja4nz.cc/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://ak.ptailadsol.net/', 'https://anlatilaninotesi.com.tr/', 'https://boobausauhipsa.net/', 'https://celebrityjest.com/',
      'https://contoseroticoscnn.com/', 'https://da88.win/', 'https://forexpipinsight.com/', 'https://ipowatch.in/',
      'https://pip.kemdikbud.go.id/', 'https://santatracker.google.com/', 'https://sga.uteq.edu.ec/', 'https://store.ankama.com/',
      'https://syria.liveuamap.com/', 'https://th.xhopen.com/', 'https://voguefashionvibe.com/', 'https://www.becaritacetina.gob.mx/',
      'https://www.cricket.com.au/', 'https://www.dailynayadiganta.com/', 'https://www.esic.in/', 'https://www.picuki.com/',
      'https://www.porn69.net/', 'https://www.shmff.gov.eg/', 'https://www.stylevamp.de/', 'https://www.swisscolony.com/',
      'https://www.tatd.in/', 'https://www.xvcams.com/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'https://adventofcode.com/', 'https://aov-news.com/', 'https://azmip.com/', 'https://chemicalssmuglyuntying.com/',
      'https://cryptonews-24.com/', 'https://dingdingding.com/', 'https://football.fantasysports.yahoo.com/', 'https://icai.nic.in/',
      'https://mall.bookcapital.com.my/', 'https://manganato.com/', 'https://nashickaltirdab.com/', 'https://point-g.rakuten.co.jp/',
      'https://psegeevalrat.net/', 'https://thisav.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://vdpro.jp/',
      'https://vip.rusvideos.day/', 'https://webxseries.net/', 'https://www.amigosecreto.com.br/', 'https://www.aocrecruitment.gov.in/',
      'https://www.biglots.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/', 'https://www.gaymec.com/',
      'https://www.gazeteduvar.com.tr/', 'https://www.grandefratello.mediaset.it/', 'https://www.portablenorthpole.com/', 'https://www.prokabaddi.com/',
      'https://www.snitch.co.in/', 'https://zrelki.link/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://cejoapsoo.net/', 'https://drawnames.app/', 'https://fantasy.nfl.com/', 'https://quaanhdaocuteo.xyz/',
      'https://ris.kfintech.com/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://www.vendeeglobe.org/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://ak.naiwoalooca.net/', 'https://biwipuque.com/', 'https://decomytree.com/',
      'https://dtruyen.net/', 'https://firhub69.com/', 'https://getmyapp.store/', 'https://gsa.teletalk.com.bd/',
      'https://linkintime.co.in/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://moviesmod.red/',
      'https://nabauxou.net/', 'https://nakarmpsa.olx.pl/', 'https://pelotainvernal.com/', 'https://sexmex.top/',
      'https://superbet.com/', 'https://tamilglitz.in/', 'https://wechoice.vn/', 'https://wfwf360.com/',
      'https://wfwf363.com/', 'https://wfwf364.com/', 'https://whoagnukrin.com/', 'https://whoucheehy.net/',
      'https://wrapup.playstation.com/', 'https://www.noradsanta.org/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://aiveemtomsaix.net/', 'https://broadensilkslush.com/', 'https://truyenfull.tv/', 'https://wfwf362.com/',
      'https://www.starbucksforlife.com/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://goboksehee.net/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://ak.ptailadsol.net/', 'https://anlatilaninotesi.com.tr/', 'https://blogherald.com/', 'https://boobausauhipsa.net/',
      'https://botdrivea.filesdl.in/', 'https://celebrityjest.com/', 'https://contoseroticoscnn.com/', 'https://da88.win/',
      'https://economy.okezone.com/', 'https://forexpipinsight.com/', 'https://ipowatch.in/', 'https://my-wishes.co/',
      'https://pip.kemdikbud.go.id/', 'https://santatracker.google.com/', 'https://sga.uteq.edu.ec/', 'https://store.ankama.com/',
      'https://syria.liveuamap.com/', 'https://th.xhopen.com/', 'https://voguefashionvibe.com/', 'https://www.becaritacetina.gob.mx/',
      'https://www.beyondlife.ink/', 'https://www.cricket.com.au/', 'https://www.dailynayadiganta.com/', 'https://www.energycue.it/',
      'https://www.esic.in/', 'https://www.picuki.com/', 'https://www.playinexchange.com/', 'https://www.porn69.net/',
      'https://www.pornjk.com/', 'https://www.shmff.gov.eg/', 'https://www.stylevamp.de/', 'https://www.swisscolony.com/',
      'https://www.tatd.in/', 'https://www.tbgameloader.com/', 'https://www.xvcams.com/', 'https://xxxcom.cam/',
      'https://yedhere3.com/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'https://312bet2.com/', 'https://54bet4.com/', 'https://adventofcode.com/', 'https://aleqaria.com.eg/',
      'https://aov-news.com/', 'https://azmip.com/', 'https://bokephit.com/', 'https://cashier.cloudspay.org/',
      'https://chemicalssmuglyuntying.com/', 'https://chromeos.dev/', 'https://cryptonews-24.com/', 'https://desipapa.watch/',
      'https://dingdingding.com/', 'https://football.fantasysports.yahoo.com/', 'https://gameshop.live/', 'https://geng39652.com/',
      'https://home89311.com/', 'https://icai.nic.in/', 'https://iq.iqraa.news/', 'https://m.24xxx.men/',
      'https://m.porno666.men/', 'https://mall.bookcapital.com.my/', 'https://manganato.com/', 'https://mlookelporno.com/',
      'https://nanas39812.com/', 'https://nashickaltirdab.com/', 'https://nyess.co.id/', 'https://on82552.com/',
      'https://point-g.rakuten.co.jp/', 'https://pro87112.com/', 'https://progorod59.ru/', 'https://psegeevalrat.net/',
      'https://ratemysoft.com/', 'https://ratukediri.com/', 'https://sd1.bestanswersforme.com/', 'https://studycafe.in/',
      'https://sugaroy.com/', 'https://thisav.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://ursextube.com/',
      'https://vdpro.jp/', 'https://vip.rusvideos.day/', 'https://web.ayoba.me/', 'https://webxseries.net/',
      'https://winbuzz.games/', 'https://www.54bet1.com/', 'https://www.alanyahaber.com/', 'https://www.amigosecreto.com.br/',
      'https://www.arabhulks.com/', 'https://www.biglots.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/',
      'https://www.expertsfaq.com/', 'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/', 'https://www.grandefratello.mediaset.it/',
      'https://www.hops.id/', 'https://www.newsnationtv.com/', 'https://www.parlons-basket.com/', 'https://www.portablenorthpole.com/',
      'https://www.prokabaddi.com/', 'https://www.snitch.co.in/', 'https://www.star-mobi-game.site/', 'https://zia82522.com/',
      'https://zrelki.link/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://blaze.com/', 'https://cejoapsoo.net/', 'https://expresswish.co/', 'https://fantasy.nfl.com/',
      'https://floree.fi/', 'https://hondagalaxy.com/', 'https://indviral.com/', 'https://m.topaipick.com/',
      'https://quaanhdaocuteo.xyz/', 'https://ris.kfintech.com/', 'https://ru.fap-guru.fun/', 'https://sd11.fastanswershere.com/',
      'https://t.t789.bet/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://www.bayburtpostasi.com.tr/', 'https://www.vendeeglobe.org/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://ak.naiwoalooca.net/', 'https://api.firstpaym.com/', 'https://biwipuque.com/',
      'https://collegeofeducation.org/', 'https://damangame.chat/', 'https://decomytree.com/', 'https://doralotto.org/',
      'https://dtruyen.net/', 'https://filmjepang.viralterbaru.wiki/', 'https://firhub69.com/', 'https://getmyapp.store/',
      'https://greerogloo.net/', 'https://gsa.teletalk.com.bd/', 'https://indiawishes.co/', 'https://librecruitmentbirbhum.in/',
      'https://linkintime.co.in/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://mt1.89k.app/',
      'https://mtg.89k.app/', 'https://nabauxou.net/', 'https://nakarmpsa.olx.pl/', 'https://parimatch1-aviator.com/',
      'https://pelotainvernal.com/', 'https://rogmovies.fun/', 'https://sexmex.top/', 'https://sports.kkxxtt.com/',
      'https://superbet.com/', 'https://tamilglitz.in/', 'https://technicalranjay.net/', 'https://wechoice.vn/',
      'https://wfwf360.com/', 'https://wfwf361.com/', 'https://wfwf363.com/', 'https://wfwf364.com/',
      'https://whoagnukrin.com/', 'https://whoucheehy.net/', 'https://win.in-pari-match.com/', 'https://wrapup.playstation.com/',
      'https://www.myjobalarm.com/', 'https://www.noradsanta.org/', 'https://www.wisesarees.com/', 'https://youpornxxxx.com/',
      'https://zip-fast-plus.com/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://aiveemtomsaix.net/', 'https://alexisayaka.com/', 'https://broadensilkslush.com/', 'https://technicalranjay.co/',
      'https://topushh.com/', 'https://truyenfull.tv/', 'https://wfwf362.com/', 'https://www.beyondmind.site/',
      'https://www.starbucksforlife.com/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://goblinx.org/', 'https://goboksehee.net/', 'https://m.new8815.cc/', 'https://sports.vvffuuww22.com/',
      'https://tarifatransacionalhoje.com/', 'https://wanli.mja4nz.cc/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/', 'https://becasbenitojuarez.net/', 'https://football.fantasysports.yahoo.com/',
      'https://ga-gcps-psv.edupoint.com/', 'https://linkintime.co.in/', 'https://mahe.gov.in/', 'https://mangamammy.ru/',
      'https://pathofexile2.com/', 'https://pip.kemdikbud.go.id/', 'https://santatracker.google.com/', 'https://store.ankama.com/',
      'https://syria.liveuamap.com/', 'https://th.xhopen.com/', 'https://ts1.x1.international.travian.com/', 'https://www.becaritacetina.gob.mx/',
      'https://www.cricket.com.au/', 'https://www.dailynayadiganta.com/', 'https://www.esic.in/', 'https://www.forever21.com/',
      'https://www.ibomma.co.in/', 'https://www.porn69.net/', 'https://www.rfa.org/', 'https://www.tatd.in/',
      'https://www.trackwrestling.com/', 'https://www.uppclonline.com/', 'https://www.xnxx.fit/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'https://adventofcode.com/', 'https://azmip.com/', 'https://basketball.fantasysports.yahoo.com/', 'https://celebrityjest.com/',
      'https://csirnetdec2024.ntaonline.in/', 'https://dingdingding.com/', 'https://fantasy.nfl.com/', 'https://footballforge.com/',
      'https://forexpipinsight.com/', 'https://icai.nic.in/', 'https://mall.bookcapital.com.my/', 'https://manganato.com/',
      'https://manysex.com/', 'https://point-g.rakuten.co.jp/', 'https://superbet.com/', 'https://thisav.com/',
      'https://ugcnetdec2024.ntaonline.in/', 'https://ujian.unnes.ac.id/', 'https://vdpro.jp/', 'https://vip.rusvideos.day/',
      'https://voguefashionvibe.com/', 'https://www.biglots.com/', 'https://www.dailydot.com/', 'https://www.drawnames.com/',
      'https://www.elfster.com/', 'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/', 'https://www.grandefratello.mediaset.it/',
      'https://www.infonieve.es/', 'https://www.karmasandhan.com/', 'https://www.portablenorthpole.com/', 'https://www.snitch.co.in/',
      'https://www.swisscolony.com/', 'https://www.vendeeglobe.org/', 'https://www.xvcams.com/', 'https://zrelki.link/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://chemicalssmuglyuntying.com/', 'https://drawnames.app/', 'https://hianime.to/', 'https://hockey.fantasysports.yahoo.com/',
      'https://ukpppg.bppp.kemdikbud.go.id/', 'https://wechoice.vn/', 'https://www.amigosecreto.com.br/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://decomytree.com/', 'https://dtruyen.net/', 'https://firhub69.com/',
      'https://getmyapp.store/', 'https://gsa.teletalk.com.bd/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/',
      'https://nakarmpsa.olx.pl/', 'https://pelotainvernal.com/', 'https://quaanhdaocuteo.xyz/', 'https://sexmex.top/',
      'https://tamilglitz.in/', 'https://wfwf360.com/', 'https://wrapup.playstation.com/', 'https://www.noradsanta.org/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://cryptonews-24.com/', 'https://wfwf363.com/', 'https://wfwf364.com/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://broadensilkslush.com/', 'https://truyenfull.tv/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/', 'https://becasbenitojuarez.net/', 'https://bet30.click/',
      'https://betterbe.co/', 'https://burmese.voanews.com/', 'https://cxid.info/', 'https://desipapa.watch/',
      'https://football.fantasysports.yahoo.com/', 'https://ga-gcps-psv.edupoint.com/', 'https://kaldagan.com/', 'https://linkintime.co.in/',
      'https://m.tamiltech.live/', 'https://m.trend-tech.net/', 'https://mahe.gov.in/', 'https://mangaku.lat/',
      'https://mangamammy.ru/', 'https://pathofexile2.com/', 'https://pgsgame.online/', 'https://pip.kemdikbud.go.id/',
      'https://santatracker.google.com/', 'https://social1.ne10.uol.com.br/', 'https://store.ankama.com/', 'https://studycafe.in/',
      'https://syria.liveuamap.com/', 'https://th.xhopen.com/', 'https://ts1.x1.international.travian.com/', 'https://txxx.tube/',
      'https://uncutmaza.xyz/', 'https://www.becaritacetina.gob.mx/', 'https://www.bet30.live/', 'https://www.betswiz.in/',
      'https://www.cricket.com.au/', 'https://www.dailynayadiganta.com/', 'https://www.esic.in/', 'https://www.forever21.com/',
      'https://www.gaveanews.com/', 'https://www.ibomma.co.in/', 'https://www.ixxx1.com/', 'https://www.lagazzettadiviareggio.it/',
      'https://www.metroworldnews.com.br/', 'https://www.playinexchange.com/', 'https://www.porn69.net/', 'https://www.rfa.org/',
      'https://www.sociedademilitar.com.br/', 'https://www.tatd.in/', 'https://www.tbgameloader.com/', 'https://www.trackwrestling.com/',
      'https://www.uppclonline.com/', 'https://www.xnxx.fit/', 'https://xnxxvids.net/', 'https://xxxcom.cam/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'https://312bet2.com/', 'https://54bet4.com/', 'https://adventofcode.com/', 'https://aleqaria.com.eg/',
      'https://arabx77.com/', 'https://azmip.com/', 'https://basketball.fantasysports.yahoo.com/', 'https://bestanswersforme.com/',
      'https://blogherald.com/', 'https://bokephit.com/', 'https://botdrivea.filesdl.in/', 'https://cashier.cloudspay.org/',
      'https://celebrityjest.com/', 'https://csirnetdec2024.ntaonline.in/', 'https://dingdingding.com/', 'https://fantasy.nfl.com/',
      'https://footballforge.com/', 'https://forexpipinsight.com/', 'https://gameshop.live/', 'https://goblinx.org/',
      'https://home89311.com/', 'https://icai.nic.in/', 'https://m.24xxx.men/', 'https://m.porno666.men/',
      'https://m.topaipick.com/', 'https://mall.bookcapital.com.my/', 'https://manganato.com/', 'https://manysex.com/',
      'https://mlookelporno.com/', 'https://my-wishes.co/', 'https://mycard10.com/', 'https://nanas39812.com/',
      'https://pangkalantoto.biz.id/', 'https://paws.community/', 'https://point-g.rakuten.co.jp/', 'https://pro87112.com/',
      'https://ratemysoft.com/', 'https://ratukediri.com/', 'https://sd1.easyfindanswers.com/', 'https://sd4.bestanswersforme.com/',
      'https://superbet.com/', 'https://thisav.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://ujian.unnes.ac.id/',
      'https://ursextube.com/', 'https://vdpro.jp/', 'https://vip.rusvideos.day/', 'https://voguefashionvibe.com/',
      'https://web.ayoba.me/', 'https://win.pari-matchin.com/', 'https://winbuzz.games/', 'https://www.54bet1.com/',
      'https://www.arabhulks.com/', 'https://www.biglots.com/', 'https://www.dailydot.com/', 'https://www.drawnames.com/',
      'https://www.elfster.com/', 'https://www.expertsfaq.com/', 'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/',
      'https://www.grandefratello.mediaset.it/', 'https://www.hops.id/', 'https://www.infonieve.es/', 'https://www.karmasandhan.com/',
      'https://www.newsnationtv.com/', 'https://www.nuitfrance.fr/', 'https://www.parlons-basket.com/', 'https://www.portablenorthpole.com/',
      'https://www.snitch.co.in/', 'https://www.swisscolony.com/', 'https://www.vendeeglobe.org/', 'https://www.xvcams.com/',
      'https://zia82522.com/', 'https://zrelki.link/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://chemicalssmuglyuntying.com/', 'https://chromeos.dev/', 'https://geng39652.com/', 'https://hianime.to/',
      'https://hockey.fantasysports.yahoo.com/', 'https://hondagalaxy.com/', 'https://luna89921.com/', 'https://on82552.com/',
      'https://pmsmahavidyalayaadmission.in/', 'https://ru.fap-guru.fun/', 'https://sugaroy.com/', 'https://ukpppg.bppp.kemdikbud.go.id/',
      'https://wechoice.vn/', 'https://www.alanyahaber.com/', 'https://www.amigosecreto.com.br/', 'https://www.bayburtpostasi.com.tr/',
      'https://www.lesdechargeurs.fr/', 'https://www.vonews.fr/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://api.firstpaym.com/', 'https://collegeofeducation.org/', 'https://damangame.chat/',
      'https://decomytree.com/', 'https://dtruyen.net/', 'https://expresswish.co/', 'https://firhub69.com/',
      'https://floree.fi/', 'https://getmyapp.store/', 'https://gsa.teletalk.com.bd/', 'https://indiawishes.co/',
      'https://indviral.com/', 'https://librecruitmentbirbhum.in/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/',
      'https://m.manganelo.com/', 'https://mt1.89k.app/', 'https://mtg.89k.app/', 'https://nakarmpsa.olx.pl/',
      'https://parimatch1-aviator.com/', 'https://pay.upi-pays.com/', 'https://pelotainvernal.com/', 'https://progorod59.ru/',
      'https://quaanhdaocuteo.xyz/', 'https://sd1.bestanswersforme.com/', 'https://sd11.fastanswershere.com/', 'https://sexmex.top/',
      'https://t.t789.bet/', 'https://tamilglitz.in/', 'https://wfwf360.com/', 'https://wrapup.playstation.com/',
      'https://www.noradsanta.org/', 'https://youpornxxxx.com/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://alexisayaka.com/', 'https://cryptonews-24.com/', 'https://filmjepang.viralterbaru.wiki/', 'https://sports.kkxxtt.com/',
      'https://technicalranjay.co/', 'https://wfwf361.com/', 'https://wfwf362.com/', 'https://wfwf363.com/',
      'https://wfwf364.com/', 'https://ww2.m4uhd.tv/', 'https://www.starbucksforlife.com/', 'https://zip-fast-plus.com/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://broadensilkslush.com/', 'https://sports.vvffuuww22.com/', 'https://topushh.com/', 'https://truyenfull.tv/',
      'https://wanli.mja4nz.cc/', 'https://www.beyondmind.site/', 'https://www.star-mobi-game.site/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/', 'https://apps.dmac-solutions.net/', 'https://becasbenitojuarez.net/',
      'https://bilimclass.kz/', 'https://cryptonews-24.com/', 'https://ders.egitimhane.com/', 'https://download.vn/',
      'https://edu.gounn.ru/', 'https://fandomwire.com/', 'https://fansided.com/', 'https://fantasy.premierleague.com/',
      'https://fisch.fandom.com/', 'https://football.fantasysports.yahoo.com/', 'https://id.soccerway.com/', 'https://kan.timotxt.com/',
      'https://login.rosettastone.com/', 'https://m.xszj.org/', 'https://mahe.gov.in/', 'https://mangathailand.com/',
      'https://math.imaginelearning.com/', 'https://my.mheducation.com/', 'https://newautopost.co.kr/', 'https://old.nz.ua/',
      'https://pip.kemdikbud.go.id/', 'https://poe2db.tw/', 'https://portal1.passportindia.gov.in/', 'https://reshak.ru/',
      'https://santatracker.google.com/', 'https://smutr.com/', 'https://store.ankama.com/', 'https://testter.kz/',
      'https://th.xhopen.com/', 'https://ukpppg.bppp.kemdikbud.go.id/', 'https://www.becaritacetina.gob.mx/', 'https://www.dailynayadiganta.com/',
      'https://www.dexerto.com/', 'https://www.esic.in/', 'https://www.forever21.com/', 'https://www.marvelrivals.com/',
      'https://www.noredink.com/', 'https://www.prcboard.com/', 'https://www.relevo.com/', 'https://www.trackwrestling.com/',
      'https://www.uppclonline.com/', 'https://xforum.live/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'http://8next.com/', 'https://adventofcode.com/', 'https://azmip.com/', 'https://celebrityjest.com/',
      'https://contoseroticoscnn.com/', 'https://csirnetdec2024.ntaonline.in/', 'https://fantasy.nfl.com/', 'https://forexpipinsight.com/',
      'https://ga-gcps-psv.edupoint.com/', 'https://gdz-raketa.ru/', 'https://icai.nic.in/', 'https://lms.moe.gov.om/',
      'https://mall.bookcapital.com.my/', 'https://mangaku.lat/', 'https://manysex.com/', 'https://news.biglobe.ne.jp/',
      'https://pathofexile2.com/', 'https://point-g.rakuten.co.jp/', 'https://resheba.top/', 'https://roundrockisd.schoology.com/',
      'https://sor-soch.com/', 'https://syria.liveuamap.com/', 'https://thisav.com/', 'https://ts2.x1.europe.travian.com/',
      'https://ts30.x3.europe.travian.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://vdpro.jp/', 'https://vip.rusvideos.day/',
      'https://voguefashionvibe.com/', 'https://vshkole.com/', 'https://www.24-hd.com/', 'https://www.biglots.com/',
      'https://www.dailydot.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/', 'https://www.euroki.org/',
      'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/', 'https://www.grandefratello.mediaset.it/', 'https://www.infonieve.es/',
      'https://www.lightnovelworld.co/', 'https://www.myvidster.com/', 'https://www.portablenorthpole.com/', 'https://www.snitch.co.in/',
      'https://www.swisscolony.com/', 'https://www.tatd.in/', 'https://www.xvcams.com/', 'https://y2mate.tube/',
      'https://zrelki.link/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://basketball.fantasysports.yahoo.com/', 'https://blaze.com/', 'https://chemicalssmuglyuntying.com/', 'https://hockey.fantasysports.yahoo.com/',
      'https://pomogalka.me/', 'https://wechoice.vn/', 'https://www.51cg1.com/', 'https://www.amigosecreto.com.br/',
      'https://www.aocrecruitment.gov.in/', 'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/',
      'https://www.lightnovelworld.com/', 'https://www.vendeeglobe.org/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://decomytree.com/', 'https://drawnames.app/', 'https://dtruyen.net/', 'https://firhub69.com/',
      'https://gsa.teletalk.com.bd/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://nakarmpsa.olx.pl/',
      'https://pelotainvernal.com/', 'https://sexmex.top/', 'https://superbet.com/', 'https://tamilglitz.in/',
      'https://wrapup.playstation.com/', 'https://www.noradsanta.org/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://getmyapp.store/', 'https://moviesmod.red/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://broadensilkslush.com/', 'https://truyenfull.tv/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://als.dfbocai.net/', 'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/', 'https://becasbenitojuarez.net/',
      'https://bilimclass.kz/', 'https://botdrivea.filesdl.in/', 'https://buzzhubspot.com/', 'https://cashstark.com/',
      'https://cryptonews-24.com/', 'https://ders.egitimhane.com/', 'https://desipapa.watch/', 'https://download.vn/',
      'https://edu.gounn.ru/', 'https://fakti.online/', 'https://fandomwire.com/', 'https://fansided.com/',
      'https://fantasy.premierleague.com/', 'https://fisch.fandom.com/', 'https://football.fantasysports.yahoo.com/', 'https://hindi.news24online.com/',
      'https://id.soccerway.com/', 'https://kan.timotxt.com/', 'https://login.rosettastone.com/', 'https://m.porno666.moe/',
      'https://m.porno666.org/', 'https://m.trend-tech.net/', 'https://m.xszj.org/', 'https://mangathailand.com/',
      'https://newautopost.co.kr/', 'https://old.nz.ua/', 'https://onlineperya.com/', 'https://pgsgame.online/',
      'https://pip.kemdikbud.go.id/', 'https://poe2db.tw/', 'https://portal1.passportindia.gov.in/', 'https://progorod59.ru/',
      'https://reshak.ru/', 'https://santatracker.google.com/', 'https://sattaking-up.com/', 'https://store.ankama.com/',
      'https://studycafe.in/', 'https://testter.kz/', 'https://th.xhopen.com/', 'https://txxx.tube/',
      'https://ukpppg.bppp.kemdikbud.go.id/', 'https://videos-zoofilia.com/', 'https://www.becaritacetina.gob.mx/', 'https://www.dailynayadiganta.com/',
      'https://www.dexerto.com/', 'https://www.esic.in/', 'https://www.forever21.com/', 'https://www.ganaencasa.win/',
      'https://www.gaveanews.com/', 'https://www.marvelrivals.com/', 'https://www.newsnationtv.com/', 'https://www.pornjk.com/',
      'https://www.prcboard.com/', 'https://www.relevo.com/', 'https://www.trackwrestling.com/', 'https://www.uppclonline.com/',
      'https://www.xnxx.fit/', 'https://xforum.live/', 'https://xnxxvids.net/', 'https://xxx.report/',
      'https://xxxcom.cam/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'http://8next.com/', 'https://312bet2.com/', 'https://54bet4.com/', 'https://adventofcode.com/',
      'https://aleqaria.com.eg/', 'https://arabx77.com/', 'https://azmip.com/', 'https://bet30.click/',
      'https://celebrityjest.com/', 'https://contoseroticoscnn.com/', 'https://csirnetdec2024.ntaonline.in/', 'https://daily.insightposts.com/',
      'https://fantasy.nfl.com/', 'https://fap-guru.fun/', 'https://forexpipinsight.com/', 'https://ga-gcps-psv.edupoint.com/',
      'https://gameshop.live/', 'https://gdz-raketa.ru/', 'https://goblinx.org/', 'https://hollywoodbets.hubtech.live/',
      'https://home89311.com/', 'https://icai.nic.in/', 'https://lms.moe.gov.om/', 'https://m.24xxx.men/',
      'https://m.porno666.men/', 'https://m.tamiltech.live/', 'https://m.topaipick.com/', 'https://mall.bookcapital.com.my/',
      'https://mangaku.lat/', 'https://manysex.com/', 'https://mlookelporno.com/', 'https://nanas39812.com/',
      'https://news.biglobe.ne.jp/', 'https://pathofexile2.com/', 'https://paws.community/', 'https://point-g.rakuten.co.jp/',
      'https://ratemysoft.com/', 'https://ratukediri.com/', 'https://resheba.top/', 'https://sd6.bestanswersforme.com/',
      'https://sor-soch.com/', 'https://syria.liveuamap.com/', 'https://thisav.com/', 'https://ts2.x1.europe.travian.com/',
      'https://ts30.x3.europe.travian.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://uncutmaza.xyz/', 'https://ursextube.com/',
      'https://vdpro.jp/', 'https://vip.rusvideos.day/', 'https://voguefashionvibe.com/', 'https://vshkole.com/',
      'https://winbuzz.games/', 'https://www.19fortyfive.com/', 'https://www.24-hd.com/', 'https://www.54bet1.com/',
      'https://www.arabhulks.com/', 'https://www.bet30.live/', 'https://www.betswiz.in/', 'https://www.biglots.com/',
      'https://www.casinozeus10.com/', 'https://www.dailydot.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/',
      'https://www.euroki.org/', 'https://www.expertsfaq.com/', 'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/',
      'https://www.grandefratello.mediaset.it/', 'https://www.hops.id/', 'https://www.infonieve.es/', 'https://www.lightnovelworld.co/',
      'https://www.metroworldnews.com.br/', 'https://www.myvidster.com/', 'https://www.portablenorthpole.com/', 'https://www.snitch.co.in/',
      'https://www.sociedademilitar.com.br/', 'https://www.swisscolony.com/', 'https://www.tatd.in/', 'https://www.tbgameloader.com/',
      'https://www.xvcams.com/', 'https://y2mate.tube/', 'https://zia82522.com/', 'https://zrelki.link/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://api.firstpaym.com/', 'https://awsar-dst.in/', 'https://basketball.fantasysports.yahoo.com/', 'https://chemicalssmuglyuntying.com/',
      'https://chromeos.dev/', 'https://geng39652.com/', 'https://hockey.fantasysports.yahoo.com/', 'https://kzgdz.com/',
      'https://luna89921.com/', 'https://mycard10.com/', 'https://on82552.com/', 'https://pomogalka.me/',
      'https://pro87112.com/', 'https://sd1.easyfindanswers.com/', 'https://sugaroy.com/', 'https://web.ayoba.me/',
      'https://wechoice.vn/', 'https://win.pari-matchin.com/', 'https://www.amigosecreto.com.br/', 'https://www.bayburtpostasi.com.tr/',
      'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/',
      'https://www.m.njcar.ru/', 'https://www.mnei.fr/', 'https://www.ncccc.in/', 'https://www.vendeeglobe.org/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://app.ogcom.xyz/', 'https://bestanswersforme.com/', 'https://blogherald.com/', 'https://cashier.cloudspay.org/',
      'https://checkout-pk.karo-pay.com/', 'https://damangame.chat/', 'https://decomytree.com/', 'https://dtruyen.net/',
      'https://expresswish.co/', 'https://firhub69.com/', 'https://floree.fi/', 'https://gsa.teletalk.com.bd/',
      'https://hindi.sportskeeda.com/', 'https://india3x.com/', 'https://indiawishes.co/', 'https://indviral.com/',
      'https://librecruitmentbirbhum.in/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://m.sek3oeb.com/',
      'https://mt1.89k.app/', 'https://nakarmpsa.olx.pl/', 'https://parimatch1-aviator.com/', 'https://pay.upi-pays.com/',
      'https://pelotainvernal.com/', 'https://ru.fap-guru.fun/', 'https://sd1.bestanswersforme.com/', 'https://sd11.fastanswershere.com/',
      'https://sd4.bestanswersforme.com/', 'https://sexmex.top/', 'https://superbet.com/', 'https://t.t789.bet/',
      'https://tamilglitz.in/', 'https://technicalranjay.net/', 'https://win.in-pari-match.com/', 'https://wrapup.playstation.com/',
      'https://www.lesdechargeurs.fr/', 'https://www.myjobalarm.com/', 'https://www.noradsanta.org/', 'https://www.nuitfrance.fr/',
      'https://www.vonews.fr/', 'https://youpornxxxx.com/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://alexisayaka.com/', 'https://download.vidshare.site/', 'https://filmjepang.viralterbaru.wiki/',
      'https://getmyapp.store/', 'https://mtg.89k.app/', 'https://pmsmahavidyalayaadmission.in/', 'https://quaanhdaocuteo.xyz/',
      'https://sports.kkxxtt.com/', 'https://technicalranjay.co/', 'https://www.alanyahaber.com/', 'https://www.starbucksforlife.com/',
      'https://zip-fast-plus.com/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://broadensilkslush.com/', 'https://hot-sex.video/', 'https://topushh.com/', 'https://truyenfull.tv/',
      'https://wanli.mja4nz.cc/', 'https://winalto.org/', 'https://www.star-mobi-game.site/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://activebeat.com/', 'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/', 'https://blocked.syd-1.linewize.net/',
      'https://educonnect.education.gouv.fr/', 'https://emaktab.uz/', 'https://familia.edu.gva.es/', 'https://fansided.com/',
      'https://fisch.fandom.com/', 'https://fqa.vn/', 'https://gdz.ru/', 'https://gol.yalla-shoot-as.com/',
      'https://ktby.net/', 'https://login.emaktab.uz/', 'https://mahe.gov.in/', 'https://mangamammy.ru/',
      'https://minhaji.net/', 'https://odsgm.meb.gov.tr/', 'https://pip.kemdikbud.go.id/', 'https://playtech.ro/',
      'https://shownews.pl/', 'https://sistemas.educacao.ma.gov.br/', 'https://smutr.com/', 'https://sso.prodigygame.com/',
      'https://start.schulportal.hessen.de/', 'https://th.xhopen.com/', 'https://ts1.x1.international.travian.com/', 'https://vdpro.jp/',
      'https://www.abcya.com/', 'https://www.commonlit.org/', 'https://www.dailynayadiganta.com/', 'https://www.deltamath.com/',
      'https://www.encancha.cl/', 'https://www.forever21.com/', 'https://www.getepic.com/', 'https://www.letmejerk.com/',
      'https://www.marvelrivals.com/', 'https://www.oba.gov.tr/', 'https://www.pagalworld.us/', 'https://www.plus.fifa.com/',
      'https://www.resultados-futbol.com/', 'https://www.splashlearn.com/', 'https://www.stylevamp.de/', 'https://www.sveedy.com/',
      'https://www.uppclonline.com/', 'https://www.xnxx.fit/', 'https://zrelki.link/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'http://8next.com/', 'https://adventofcode.com/', 'https://apps.dmac-solutions.net/', 'https://azmip.com/',
      'https://becasbenitojuarez.net/', 'https://conjuguemos.com/', 'https://cryptonews-24.com/', 'https://csirnetdec2024.ntaonline.in/',
      'https://dnevnik.ru/', 'https://edu.rk.gov.ru/', 'https://eduvulcan.pl/', 'https://ga-gcps-psv.edupoint.com/',
      'https://gdz-raketa.ru/', 'https://ibomma1.com/', 'https://id.soccerway.com/', 'https://lms.moe.gov.om/',
      'https://login.rosettastone.com/', 'https://m.xszj.org/', 'https://mangathailand.com/', 'https://manysex.com/',
      'https://math.imaginelearning.com/', 'https://me.classera.com/', 'https://my.mheducation.com/', 'https://nordot.app/',
      'https://okulizyon.com/', 'https://old.nz.ua/', 'https://pathofexile2.com/', 'https://peppagame.com/',
      'https://poe2db.tw/', 'https://point-g.rakuten.co.jp/', 'https://pomahach.com/', 'https://pornhuts.one/',
      'https://portal1.passportindia.gov.in/', 'https://reshak.ru/', 'https://resheba.top/', 'https://santatracker.google.com/',
      'https://scorenga.com/', 'https://sexpebune.ro/', 'https://sms.schoolsoft.se/', 'https://subscriptions.teachtci.com/',
      'https://testter.kz/', 'https://thisav.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://ujian.unnes.ac.id/',
      'https://vip.rusvideos.day/', 'https://vshkole.com/', 'https://www.brainpop.com/', 'https://www.crhoy.com/',
      'https://www.dailydot.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/', 'https://www.euroki.org/',
      'https://www.evvelcevap.com/', 'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/', 'https://www.grandefratello.mediaset.it/',
      'https://www.hululktaab.com/', 'https://www.infonieve.es/', 'https://www.investireoggi.it/', 'https://www.naturecaptions.com/',
      'https://www.ncaa.com/', 'https://www.noredink.com/', 'https://www.portablenorthpole.com/', 'https://www.prcboard.com/',
      'https://www.quill.org/', 'https://www.relevo.com/', 'https://www.snitch.co.in/', 'https://www.swisscolony.com/',
      'https://www.tatd.in/', 'https://www.test-uz.ru/', 'https://www.trackwrestling.com/', 'https://www.wajibati.net/',
      'https://www.xvcams.com/', 'https://y2mate.tube/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://basketball.fantasysports.yahoo.com/', 'https://blaze.com/', 'https://dtruyen.net/', 'https://hockey.fantasysports.yahoo.com/',
      'https://pomogalka.me/', 'https://roundrockisd.schoology.com/', 'https://www.amigosecreto.com.br/', 'https://www.aocrecruitment.gov.in/',
      'https://www.biglots.com/', 'https://www.ibomma.co.in/', 'https://www.lightnovelworld.co/', 'https://www.myvidster.com/',
      'https://www.vendeeglobe.org/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://decomytree.com/', 'https://drawnames.app/', 'https://firhub69.com/', 'https://lms.tnsed.com/',
      'https://lokapai.ppgkemenag.com/', 'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/', 'https://pelotainvernal.com/',
      'https://sexmex.top/', 'https://sor-soch.com/', 'https://superbet.com/', 'https://tamilglitz.in/',
      'https://ts3.x1.europe.travian.com/', 'https://wechoice.vn/', 'https://wrapup.playstation.com/', 'https://www.karmasandhan.com/',
      'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/', 'https://www.noradsanta.org/', 'https://www.thebay.com/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://quaanhdaocuteo.xyz/', 'https://uaserial.com/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://truyenfull.tv/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://11xplay.pro/', 'https://activebeat.com/', 'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/',
      'https://botdrivea.filesdl.in/', 'https://cashstark.com/', 'https://desipapa.watch/', 'https://edatv.news/',
      'https://educonnect.education.gouv.fr/', 'https://fakti.online/', 'https://familia.edu.gva.es/', 'https://fansided.com/',
      'https://fisch.fandom.com/', 'https://fqa.vn/', 'https://gdz.ru/', 'https://gol.yalla-shoot-as.com/',
      'https://ktby.net/', 'https://laser247.club/', 'https://login.emaktab.uz/', 'https://m.dfbocai.net/',
      'https://m.porno666.moe/', 'https://m.porno666.org/', 'https://mahe.gov.in/', 'https://mangamammy.ru/',
      'https://minhaji.net/', 'https://odsgm.meb.gov.tr/', 'https://pip.kemdikbud.go.id/', 'https://playtech.ro/',
      'https://portaldopalmeirense.com.br/', 'https://progorod59.ru/', 'https://ratemysoft.com/', 'https://shownews.pl/',
      'https://sistemas.educacao.ma.gov.br/', 'https://smakosze.pl/', 'https://smutr.com/', 'https://sport.playauto.cloud/',
      'https://sso.prodigygame.com/', 'https://start.schulportal.hessen.de/', 'https://th.xhopen.com/', 'https://ts1.x1.international.travian.com/',
      'https://txxx.tube/', 'https://uncutmaza.xyz/', 'https://vdpro.jp/', 'https://www.bugetul.ro/',
      'https://www.commonlit.org/', 'https://www.dailynayadiganta.com/', 'https://www.deltamath.com/', 'https://www.encancha.cl/',
      'https://www.forever21.com/', 'https://www.gaveanews.com/', 'https://www.ibahia.com/', 'https://www.letmejerk.com/',
      'https://www.marvelrivals.com/', 'https://www.metroworldnews.com.br/', 'https://www.nesiatimes.com/', 'https://www.oba.gov.tr/',
      'https://www.okmag.gr/', 'https://www.pagalworld.us/', 'https://www.parlons-basket.com/', 'https://www.plus.fifa.com/',
      'https://www.shownieuws.nl/', 'https://www.splashlearn.com/', 'https://www.stylevamp.de/', 'https://www.sveedy.com/',
      'https://www.uppclonline.com/', 'https://www.xnxx.fit/', 'https://xnxxvids.net/', 'https://xxx.report/',
      'https://xxxcom.cam/', 'https://yakutiamedia.ru/', 'https://youhdjizz.com/', 'https://zrelki.link/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'http://8next.com/', 'https://312bet2.com/', 'https://54bet4.com/', 'https://adcloudeconomy.com/',
      'https://adventofcode.com/', 'https://als.dfbocai.net/', 'https://api.firstpaym.com/', 'https://apkhihe.net/',
      'https://app.ogcom.xyz/', 'https://arabx77.com/', 'https://azmip.com/', 'https://becasbenitojuarez.net/',
      'https://bet30.click/', 'https://buzzhubspot.com/', 'https://cryptonews-24.com/', 'https://csirnetdec2024.ntaonline.in/',
      'https://daily.insightposts.com/', 'https://dnevnik.ru/', 'https://edu.gounn.ru/', 'https://edu.rk.gov.ru/',
      'https://eduvulcan.pl/', 'https://fap-guru.fun/', 'https://ga-gcps-psv.edupoint.com/', 'https://gameshop.live/',
      'https://gdz-raketa.ru/', 'https://goblinx.org/', 'https://home89311.com/', 'https://ibomma1.com/',
      'https://id.soccerway.com/', 'https://isolatedovercomepasted.com/', 'https://lms.moe.gov.om/', 'https://login.rosettastone.com/',
      'https://m.porno666.men/', 'https://m.sek3oeb.com/', 'https://m.tamiltech.live/', 'https://m.topaipick.com/',
      'https://m.xszj.org/', 'https://mangathailand.com/', 'https://manysex.com/', 'https://me.classera.com/',
      'https://mlookelporno.com/', 'https://modcombo.com/', 'https://my-wishes.co/', 'https://nanas39812.com/',
      'https://nordot.app/', 'https://okulizyon.com/', 'https://old.nz.ua/', 'https://onlineperya.com/',
      'https://pathofexile2.com/', 'https://paws.community/', 'https://peppagame.com/', 'https://pgsgame.online/',
      'https://poe2db.tw/', 'https://point-g.rakuten.co.jp/', 'https://pomahach.com/', 'https://pornhuts.one/',
      'https://portal1.passportindia.gov.in/', 'https://ratukediri.com/', 'https://reshak.ru/', 'https://resheba.top/',
      'https://santatracker.google.com/', 'https://sattaking-up.com/', 'https://scorenga.com/', 'https://sexpebune.ro/',
      'https://sms.schoolsoft.se/', 'https://studycafe.in/', 'https://tamil.hindustantimes.com/', 'https://testter.kz/',
      'https://thechopal.com/', 'https://thisav.com/', 'https://ugcnetdec2024.ntaonline.in/', 'https://ujian.unnes.ac.id/',
      'https://ukr.media/', 'https://ursextube.com/', 'https://videos-zoofilia.com/', 'https://vip.rusvideos.day/',
      'https://vshkole.com/', 'https://winbuzz.games/', 'https://www.54bet1.com/', 'https://www.arabhulks.com/',
      'https://www.betswiz.in/', 'https://www.crhoy.com/', 'https://www.dailydot.com/', 'https://www.drawnames.com/',
      'https://www.elfster.com/', 'https://www.euroki.org/', 'https://www.evvelcevap.com/', 'https://www.expertsfaq.com/',
      'https://www.gaymec.com/', 'https://www.gazeteduvar.com.tr/', 'https://www.grandefratello.mediaset.it/', 'https://www.hops.id/',
      'https://www.hululktaab.com/', 'https://www.infonieve.es/', 'https://www.investireoggi.it/', 'https://www.naturecaptions.com/',
      'https://www.ncaa.com/', 'https://www.newsnationtv.com/', 'https://www.portablenorthpole.com/', 'https://www.prcboard.com/',
      'https://www.relevo.com/', 'https://www.snitch.co.in/', 'https://www.swisscolony.com/', 'https://www.tatd.in/',
      'https://www.tbgameloader.com/', 'https://www.test-uz.ru/', 'https://www.trackwrestling.com/', 'https://www.wajibati.net/',
      'https://www.xvcams.com/', 'https://y2mate.tube/', 'https://zia82522.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://adcloudbusiness.com/', 'https://basketball.fantasysports.yahoo.com/', 'https://bestanswersforme.com/', 'https://chromeos.dev/',
      'https://dtruyen.net/', 'https://hockey.fantasysports.yahoo.com/', 'https://kzgdz.com/', 'https://luna89921.com/',
      'https://on82552.com/', 'https://pomogalka.me/', 'https://pro87112.com/', 'https://sugaroy.com/',
      'https://web.ayoba.me/', 'https://www.19fortyfive.com/', 'https://www.amigosecreto.com.br/', 'https://www.bayburtpostasi.com.tr/',
      'https://www.biglots.com/', 'https://www.ibomma.co.in/', 'https://www.lagazzettadiviareggio.it/', 'https://www.lightnovelworld.co/',
      'https://www.motorzoom.it/', 'https://www.myvidster.com/', 'https://www.vendeeglobe.org/', 'https://xvdesi.org/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://awsar-dst.in/', 'https://betterbe.co/', 'https://bigwinbuzz.com/', 'https://blogherald.com/',
      'https://checkout-pk.karo-pay.com/', 'https://chemicalssmuglyuntying.com/', 'https://damangame.chat/', 'https://decomytree.com/',
      'https://expresswish.co/', 'https://firhub69.com/', 'https://floree.fi/', 'https://geng39652.com/',
      'https://hollywoodbets.hubtech.live/', 'https://indviral.com/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/',
      'https://m.tub4exer.com/', 'https://mt1.89k.app/', 'https://mycard10.com/', 'https://nakarmpsa.olx.pl/',
      'https://news.biglobe.ne.jp/', 'https://parimatch1-aviator.com/', 'https://pay.moonspay.net/', 'https://pay.upi-pays.com/',
      'https://pelotainvernal.com/', 'https://pmsmahavidyalayaadmission.in/', 'https://ru.fap-guru.fun/', 'https://sd1.bestanswersforme.com/',
      'https://sd1.easyfindanswers.com/', 'https://sd4.bestanswersforme.com/', 'https://sd6.bestanswersforme.com/', 'https://sexmex.top/',
      'https://sor-soch.com/', 'https://superbet.com/', 'https://tamilglitz.in/', 'https://technicalranjay.net/',
      'https://ts3.x1.europe.travian.com/', 'https://wechoice.vn/', 'https://win.in-pari-match.com/', 'https://win.pari-matchin.com/',
      'https://wrapup.playstation.com/', 'https://ww.mydesi2.mobi/', 'https://www.casinozeus10.com/', 'https://www.karmasandhan.com/',
      'https://www.lesdechargeurs.fr/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/', 'https://www.mnei.fr/',
      'https://www.myjobalarm.com/', 'https://www.ncccc.in/', 'https://www.noradsanta.org/', 'https://www.nuitfrance.fr/',
      'https://www.seneporno.com/', 'https://www.thebay.com/', 'https://www.vonews.fr/', 'https://youpornxxxx.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://alexisayaka.com/', 'https://cashier.cloudspay.org/', 'https://download.vidshare.site/',
      'https://filmjepang.viralterbaru.wiki/', 'https://getmyapp.store/', 'https://indiawishes.co/', 'https://mtg.89k.app/',
      'https://quaanhdaocuteo.xyz/', 'https://sd11.fastanswershere.com/', 'https://technicalranjay.co/', 'https://uaserial.com/',
      'https://www.alanyahaber.com/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://sports.kkxxtt.com/', 'https://topushh.com/', 'https://truyenfull.tv/', 'https://zip-fast-plus.com/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'http://himasoku.com/', 'https://activebeat.com/', 'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/',
      'https://castleapps.org/', 'https://edu.rk.gov.ru/', 'https://familia.edu.gva.es/', 'https://fandomwire.com/',
      'https://fansided.com/', 'https://fqa.vn/', 'https://ga-gcps-psv.edupoint.com/', 'https://gdz-raketa.ru/',
      'https://haberglobal.com.tr/', 'https://linkintime.co.in/', 'https://mahe.gov.in/', 'https://mangamammy.ru/',
      'https://missav.com/', 'https://odsgm.meb.gov.tr/', 'https://peppagame.com/', 'https://playtech.ro/',
      'https://smutr.com/', 'https://sprunkin.com/', 'https://store.ankama.com/', 'https://testter.kz/',
      'https://th.xhopen.com/', 'https://ugcnet.nta.ac.in/', 'https://vdpro.jp/', 'https://wsec06.bancogalicia.com.ar/',
      'https://www.crhoy.com/', 'https://www.encancha.cl/', 'https://www.forever21.com/', 'https://www.investireoggi.it/',
      'https://www.letmejerk.com/', 'https://www.marvelrivals.com/', 'https://www.plus.fifa.com/', 'https://www.sveedy.com/',
      'https://www.svenskdam.se/', 'https://www.uppclonline.com/', 'https://www.wittytv.it/', 'https://www.xnxx.fit/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'http://8next.com/', 'https://adventofcode.com/', 'https://azmip.com/', 'https://basketball.fantasysports.yahoo.com/',
      'https://csirnetdec2024.ntaonline.in/', 'https://dtruyen.net/', 'https://edu.gounn.ru/', 'https://gamerxyt.com/',
      'https://hockey.fantasysports.yahoo.com/', 'https://ibomma1.com/', 'https://icai.nic.in/', 'https://id.soccerway.com/',
      'https://kr72.sogirl.so/', 'https://lms.moe.gov.om/', 'https://login.rosettastone.com/', 'https://mangathailand.com/',
      'https://okulizyon.com/', 'https://old.nz.ua/', 'https://pip.kemdikbud.go.id/', 'https://point-g.rakuten.co.jp/',
      'https://pomahach.com/', 'https://pomogalka.me/', 'https://portal1.passportindia.gov.in/', 'https://reshak.ru/',
      'https://resheba.top/', 'https://santatracker.google.com/', 'https://scorenga.com/', 'https://shownews.pl/',
      'https://thisav.com/', 'https://vip.rusvideos.day/', 'https://vshkole.com/', 'https://www.biglots.com/',
      'https://www.dailydot.com/', 'https://www.dailynayadiganta.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/',
      'https://www.euroki.org/', 'https://www.evvelcevap.com/', 'https://www.gaymec.com/', 'https://www.grandefratello.mediaset.it/',
      'https://www.infonieve.es/', 'https://www.mastertheenglish.com/', 'https://www.myvidster.com/', 'https://www.naturecaptions.com/',
      'https://www.pagalworld.us/', 'https://www.portablenorthpole.com/', 'https://www.relevo.com/', 'https://www.swisscolony.com/',
      'https://www.tatd.in/', 'https://www.test-uz.ru/', 'https://www.trackwrestling.com/', 'https://www.xvcams.com/',
      'https://y2mate.tube/', 'https://zrelki.link/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://becasbenitojuarez.net/', 'https://cryptonews-24.com/', 'https://drawnames.app/', 'https://honghotduongpho.com/',
      'https://nordot.app/', 'https://pornhuts.one/', 'https://sexpebune.ro/', 'https://ujian.unnes.ac.id/',
      'https://www.amigosecreto.com.br/', 'https://www.aocrecruitment.gov.in/', 'https://www.lightnovelworld.co/', 'https://www.snitch.co.in/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://chemicalssmuglyuntying.com/', 'https://decomytree.com/', 'https://fapello.ru/', 'https://firhub69.com/',
      'https://gazetki.kaufino.com/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/', 'https://news.biglobe.ne.jp/',
      'https://nurseryrhymestv.com/', 'https://pelotainvernal.com/', 'https://sexmex.top/', 'https://sor-soch.com/',
      'https://superbet.com/', 'https://tamilglitz.in/', 'https://ugcnetdec2024.ntaonline.in/', 'https://wechoice.vn/',
      'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/',
      'https://www.noradsanta.org/', 'https://www.thebay.com/', 'https://www.vendeeglobe.org/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://nakarmpsa.olx.pl/', 'https://oswaalbooks.com/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://quaanhdaocuteo.xyz/', 'https://truyenfull.tv/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'http://himasoku.com/', 'https://11xplay.pro/', 'https://159.games/', 'https://activebeat.com/',
      'https://anlatilaninotesi.com.tr/', 'https://aov-news.com/', 'https://apkhihe.net/', 'https://botdrivea.filesdl.in/',
      'https://cashstark.com/', 'https://castleapps.org/', 'https://desipapa.watch/', 'https://edatv.news/',
      'https://edu.rk.gov.ru/', 'https://fakti.online/', 'https://familia.edu.gva.es/', 'https://fandomwire.com/',
      'https://fansided.com/', 'https://fqa.vn/', 'https://fuckingvideos.co/', 'https://ga-gcps-psv.edupoint.com/',
      'https://gadget.viva.co.id/', 'https://gdz-raketa.ru/', 'https://haberglobal.com.tr/', 'https://in3xnet.com/',
      'https://laser247.club/', 'https://linkintime.co.in/', 'https://m.24xxx.party/', 'https://m.dfbocai.net/',
      'https://m.porno666.moe/', 'https://m.porno666.org/', 'https://mahe.gov.in/', 'https://mangamammy.ru/',
      'https://mcashier.dfbocai.net/', 'https://missav.com/', 'https://numberticket.jp/', 'https://odsgm.meb.gov.tr/',
      'https://peppagame.com/', 'https://playtech.ro/', 'https://seucreditodigital.com.br/', 'https://smutr.com/',
      'https://sprunkin.com/', 'https://store.ankama.com/', 'https://testter.kz/', 'https://th.xhopen.com/',
      'https://txxx.tube/', 'https://ugcnet.nta.ac.in/', 'https://uncutmaza.xyz/', 'https://vdpro.jp/',
      'https://vidmateapp.tools/', 'https://wsec06.bancogalicia.com.ar/', 'https://www.bet30pro.com/', 'https://www.bugetul.ro/',
      'https://www.crhoy.com/', 'https://www.dailyharbour.com/', 'https://www.encancha.cl/', 'https://www.forever21.com/',
      'https://www.foxsports.com.mx/', 'https://www.ibahia.com/', 'https://www.investireoggi.it/', 'https://www.letmejerk.com/',
      'https://www.marvelrivals.com/', 'https://www.okmag.gr/', 'https://www.plus.fifa.com/', 'https://www.shownieuws.nl/',
      'https://www.sveedy.com/', 'https://www.svenskdam.se/', 'https://www.thehealthsite.com/', 'https://www.thueringen24.de/',
      'https://www.uppclonline.com/', 'https://www.wittytv.it/', 'https://www.xnxx.fit/', 'https://xnxxvids.net/',
      'https://xxx.report/', 'https://youhdjizz.com/', 'https://zk.znaj.ua/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'http://8next.com/', 'https://312bet2.com/', 'https://adventofcode.com/', 'https://app.ogcom.xyz/',
      'https://arabx77.com/', 'https://azmip.com/', 'https://basketball.fantasysports.yahoo.com/', 'https://bet30.click/',
      'https://collective.world/', 'https://crictoday.com/', 'https://csirnetdec2024.ntaonline.in/', 'https://daily.insightposts.com/',
      'https://dtruyen.net/', 'https://edu.gounn.ru/', 'https://fap-guru.fun/', 'https://gamerxyt.com/',
      'https://goblinx.org/', 'https://hockey.fantasysports.yahoo.com/', 'https://home89311.com/', 'https://ibomma1.com/',
      'https://icai.nic.in/', 'https://id.soccerway.com/', 'https://isolatedovercomepasted.com/', 'https://kr72.sogirl.so/',
      'https://kzgdz.com/', 'https://lms.moe.gov.om/', 'https://login.rosettastone.com/', 'https://m.porno666.men/',
      'https://m.sek3oeb.com/', 'https://m.tamiltech.live/', 'https://m.topaipick.com/', 'https://m.tub4exer.com/',
      'https://mangathailand.com/', 'https://mlookelporno.com/', 'https://modcombo.com/', 'https://my-wishes.co/',
      'https://okulizyon.com/', 'https://old.nz.ua/', 'https://onlineperya.com/', 'https://paws.community/',
      'https://pgsgame.online/', 'https://pip.kemdikbud.go.id/', 'https://point-g.rakuten.co.jp/', 'https://pomahach.com/',
      'https://pomogalka.me/', 'https://portal1.passportindia.gov.in/', 'https://portaldopalmeirense.com.br/', 'https://progorod33.ru/',
      'https://ratemysoft.com/', 'https://reshak.ru/', 'https://resheba.top/', 'https://santatracker.google.com/',
      'https://scorenga.com/', 'https://shownews.pl/', 'https://smakosze.pl/', 'https://tamil.hindustantimes.com/',
      'https://techsvet.cz/', 'https://thisav.com/', 'https://ukr.media/', 'https://ursextube.com/',
      'https://videos-zoofilia.com/', 'https://vip.rusvideos.day/', 'https://vshkole.com/', 'https://web.tubxporn.com/',
      'https://winbuzz.games/', 'https://www.arabhulks.com/', 'https://www.biglots.com/', 'https://www.dailydot.com/',
      'https://www.dailynayadiganta.com/', 'https://www.drawnames.com/', 'https://www.elfster.com/', 'https://www.euroki.org/',
      'https://www.evvelcevap.com/', 'https://www.gaymec.com/', 'https://www.grandefratello.mediaset.it/', 'https://www.infonieve.es/',
      'https://www.karlsruhe-insider.de/', 'https://www.mastertheenglish.com/', 'https://www.myvidster.com/', 'https://www.naturecaptions.com/',
      'https://www.nesiatimes.com/', 'https://www.newsnationtv.com/', 'https://www.pagalworld.us/', 'https://www.parlons-basket.com/',
      'https://www.portablenorthpole.com/', 'https://www.redactie24.be/', 'https://www.relevo.com/', 'https://www.swisscolony.com/',
      'https://www.tatd.in/', 'https://www.tbgameloader.com/', 'https://www.test-uz.ru/', 'https://www.trackwrestling.com/',
      'https://www.xvcams.com/', 'https://xvdesi.org/', 'https://xxxcom.cam/', 'https://y2mate.tube/',
      'https://zrelki.link/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://54bet4.com/', 'https://adcloudeconomy.com/', 'https://becasbenitojuarez.net/', 'https://bestanswersforme.com/',
      'https://chromeos.dev/', 'https://cryptonews-24.com/', 'https://gameshop.live/', 'https://honghotduongpho.com/',
      'https://luna89921.com/', 'https://nanas39812.com/', 'https://nordot.app/', 'https://pornhuts.one/',
      'https://pro87112.com/', 'https://seneporno.com/', 'https://sexpebune.ro/', 'https://sport.playauto.cloud/',
      'https://studycafe.in/', 'https://sugaroy.com/', 'https://ujian.unnes.ac.id/', 'https://web.ayoba.me/',
      'https://www.19fortyfive.com/', 'https://www.54bet1.com/', 'https://www.amigosecreto.com.br/', 'https://www.bayburtpostasi.com.tr/',
      'https://www.betswiz.in/', 'https://www.crossthegame.com/', 'https://www.iaagamego.com/', 'https://www.lightnovelworld.co/',
      'https://www.snitch.co.in/', 'https://www.terra.com/', 'https://www1.celuapuestas.io/', 'https://zia82522.com/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://adcloudbusiness.com/', 'https://awsar-dst.in/', 'https://betterbe.co/', 'https://chemicalssmuglyuntying.com/',
      'https://cxid.info/', 'https://damangame.chat/', 'https://decomytree.com/', 'https://expresswish.co/',
      'https://fapello.ru/', 'https://firhub69.com/', 'https://floree.fi/', 'https://gazetki.kaufino.com/',
      'https://geng39652.com/', 'https://indviral.com/', 'https://lms.tnsed.com/', 'https://lokapai.ppgkemenag.com/',
      'https://mp3uk.net/', 'https://mt1.89k.app/', 'https://mtg.89k.app/', 'https://mycard10.com/',
      'https://news.biglobe.ne.jp/', 'https://nurseryrhymestv.com/', 'https://on82552.com/', 'https://parimatch1-aviator.com/',
      'https://pelotainvernal.com/', 'https://ratukediri.com/', 'https://ru.fap-guru.fun/', 'https://sd1.easyfindanswers.com/',
      'https://sd4.bestanswersforme.com/', 'https://sd6.bestanswersforme.com/', 'https://sexmex.top/', 'https://sor-soch.com/',
      'https://superbet.com/', 'https://tamilglitz.in/', 'https://technicalranjay.net/', 'https://thechopal.com/',
      'https://ugcnetdec2024.ntaonline.in/', 'https://wapbold.net/', 'https://wechoice.vn/', 'https://win.in-pari-match.com/',
      'https://win.pari-matchin.com/', 'https://ww.mydesi2.mobi/', 'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/',
      'https://www.lagazzettadiviareggio.it/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/', 'https://www.mnei.fr/',
      'https://www.motorzoom.it/', 'https://www.myjobalarm.com/', 'https://www.ncccc.in/', 'https://www.noradsanta.org/',
      'https://www.nuitfrance.fr/', 'https://www.seneporno.com/', 'https://www.thebay.com/', 'https://www.vendeeglobe.org/',
      'https://www.vonews.fr/', 'https://youpornxxxx.com/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://8171.bisp.gov.pk/', 'https://bigwinbuzz.com/', 'https://blogherald.com/', 'https://buzzhubspot.com/',
      'https://cashier.cloudspay.org/', 'https://checkout-pk.karo-pay.com/', 'https://filmjepang.viralterbaru.wiki/', 'https://getmyapp.store/',
      'https://hollywoodbets.hubtech.live/', 'https://indiawishes.co/', 'https://moviesda.page/', 'https://nakarmpsa.olx.pl/',
      'https://oswaalbooks.com/', 'https://pay.upi-pays.com/', 'https://sd1.bestanswersforme.com/', 'https://sd11.fastanswershere.com/',
      'https://www.casinozeus10.com/', 'https://www.lesdechargeurs.fr/', 'https://www.starbucksforlife.com/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://alexisayaka.com/', 'https://download.vidshare.site/', 'https://quaanhdaocuteo.xyz/',
      'https://sports.kkxxtt.com/', 'https://technicalranjay.co/', 'https://topushh.com/', 'https://truyenfull.tv/',
      'https://wanli.mja4nz.cc/', 'https://www.alanyahaber.com/', 'https://zip-fast-plus.com/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://activebeat.com/', 'https://anlatilaninotesi.com.tr/', 'https://app.gradient.network/', 'https://contoseroticoscnn.com/',
      'https://entretenimento.r7.com/', 'https://fandomwire.com/', 'https://fapnfuck.com/', 'https://ga-gcps-psv.edupoint.com/',
      'https://haberglobal.com.tr/', 'https://javidol.org/', 'https://katmoviehd.nexus/', 'https://kinogo.fm/',
      'https://mahe.gov.in/', 'https://mangamammy.ru/', 'https://manysex.com/', 'https://missav.com/',
      'https://newautopost.co.kr/', 'https://peppagame.com/', 'https://pinterestdownloader.com/', 'https://podolyaka.ru/',
      'https://portal2.passportindia.gov.in/', 'https://ris.kfintech.com/', 'https://santatracker.google.com/', 'https://sexmotarjam.com/',
      'https://shownews.pl/', 'https://sistemas.educacao.ma.gov.br/', 'https://smutr.com/', 'https://sprunkin.com/',
      'https://th.xhopen.com/', 'https://www.crhoy.com/', 'https://www.dailyjanakantha.com/', 'https://www.dailynayadiganta.com/',
      'https://www.fingerhut.com/', 'https://www.forever21.com/', 'https://www.letmejerk.com/', 'https://www.marvelrivals.com/',
      'https://www.sveedy.com/', 'https://www.svenskdam.se/', 'https://www.swisscolony.com/', 'https://www.tatd.in/',
      'https://www.techinsider.ru/', 'https://www.themirror.com/', 'https://www.trackwrestling.com/', 'https://www.tv100.com/',
      'https://www.xnxx.fit/', 'https://www.y2mate.com/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'http://himasoku.com/', 'https://adventofcode.com/', 'https://drawnames.app/', 'https://dtruyen.net/',
      'https://fansided.com/', 'https://fapello.ru/', 'https://fqa.vn/', 'https://gol.yalla-shoot-as.com/',
      'https://icai.nic.in/', 'https://id.soccerway.com/', 'https://login.rosettastone.com/', 'https://m.anwap.love/',
      'https://mangathailand.com/', 'https://melbet.com/', 'https://nordot.app/', 'https://pip.kemdikbud.go.id/',
      'https://point-g.rakuten.co.jp/', 'https://portal1.passportindia.gov.in/', 'https://scorenga.com/', 'https://sor-soch.com/',
      'https://thisav.com/', 'https://ts30.x3.asia.travian.com/', 'https://ts30.x3.europe.travian.com/', 'https://uaserial.com/',
      'https://ujian.unnes.ac.id/', 'https://vdpro.jp/', 'https://vip.rusvideos.day/', 'https://wsec06.bancogalicia.com.ar/',
      'https://www.amigosecreto.com.br/', 'https://www.dailydot.com/', 'https://www.elfster.com/', 'https://www.encancha.cl/',
      'https://www.grandefratello.mediaset.it/', 'https://www.infonieve.es/', 'https://www.mastertheenglish.com/', 'https://www.pagalworld.us/',
      'https://www.portablenorthpole.com/', 'https://www.relevo.com/', 'https://www.snitch.co.in/', 'https://www.uppclonline.com/',
      'https://www.xvcams.com/', 'https://y2mate.tube/', 'https://zrelki.link/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://becasbenitojuarez.net/', 'https://blaze.com/', 'https://csirnetdec2024.ntaonline.in/', 'https://dramacool.bg/',
      'https://firhub69.com/', 'https://ibomma1.com/', 'https://lms.tnsed.com/', 'https://pornhuts.one/',
      'https://sexpebune.ro/', 'https://www.aocrecruitment.gov.in/', 'https://www.biglots.com/', 'https://www.lightnovelworld.co/',
      'https://www.naturecaptions.com/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://decomytree.com/', 'https://honghotduongpho.com/', 'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/',
      'https://pelotainvernal.com/', 'https://r.dofustream.cloud/', 'https://sexmex.top/', 'https://superbet.com/',
      'https://tamilglitz.in/', 'https://ugcnetdec2024.ntaonline.in/', 'https://wechoice.vn/', 'https://www.ibomma.co.in/',
      'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/', 'https://www.noradsanta.org/',
      'https://www.thebay.com/', 'https://www.vendeeglobe.org/', 'https://xprimehub.vip/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://www.ballzaa.com/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://chemicalssmuglyuntying.com/', 'https://cryptonews-24.com/', 'https://gazetki.kaufino.com/',
      'https://quaanhdaocuteo.xyz/', 'https://truyenfull.tv/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://11xplay.pro/', 'https://a7-satta.com/', 'https://activebeat.com/', 'https://anlatilaninotesi.com.tr/',
      'https://app.gradient.network/', 'https://catracalivre.com.br/', 'https://contoseroticoscnn.com/', 'https://desipapa.watch/',
      'https://elintransigente.com/', 'https://entretenimento.r7.com/', 'https://fakti.online/', 'https://fandomwire.com/',
      'https://fapnfuck.com/', 'https://ga-gcps-psv.edupoint.com/', 'https://haberglobal.com.tr/', 'https://hackerdoslot2.com/',
      'https://in3xnet.com/', 'https://javidol.org/', 'https://katmoviehd.nexus/', 'https://kinogo.fm/',
      'https://laser247.club/', 'https://m.dfbocai.net/', 'https://m.porno666.moe/', 'https://m.porno666.org/',
      'https://mahe.gov.in/', 'https://mangamammy.ru/', 'https://manysex.com/', 'https://mcashier.dfbocai.net/',
      'https://missav.com/', 'https://mxseries.com.co/', 'https://newautopost.co.kr/', 'https://peppagame.com/',
      'https://pinterestdownloader.com/', 'https://podolyaka.ru/', 'https://portal2.passportindia.gov.in/', 'https://ratemysoft.com/',
      'https://ris.kfintech.com/', 'https://santatracker.google.com/', 'https://seucreditodigital.com.br/', 'https://sexmotarjam.com/',
      'https://shownews.pl/', 'https://sistemas.educacao.ma.gov.br/', 'https://smutr.com/', 'https://spilleddaily.com/',
      'https://sprunkin.com/', 'https://th.xhopen.com/', 'https://txxx.tube/', 'https://vip.24xxx.party/',
      'https://vologda-poisk.ru/', 'https://www.baji999.in/', 'https://www.bet30pro.com/', 'https://www.bugetul.ro/',
      'https://www.crhoy.com/', 'https://www.dailyjanakantha.com/', 'https://www.dailynayadiganta.com/', 'https://www.energycue.it/',
      'https://www.fingerhut.com/', 'https://www.forever21.com/', 'https://www.getsurrey.co.uk/', 'https://www.ibahia.com/',
      'https://www.letmejerk.com/', 'https://www.marvelrivals.com/', 'https://www.masculin.com/', 'https://www.metroworldnews.com.br/',
      'https://www.nesiatimes.com/', 'https://www.okmag.gr/', 'https://www.shownieuws.nl/', 'https://www.sveedy.com/',
      'https://www.svenskdam.se/', 'https://www.swisscolony.com/', 'https://www.tatd.in/', 'https://www.techinsider.ru/',
      'https://www.thehealthsite.com/', 'https://www.themirror.com/', 'https://www.thueringen24.de/', 'https://www.trackwrestling.com/',
      'https://www.tv100.com/', 'https://www.xnxx.fit/', 'https://www.y2mate.com/', 'https://yop.l-frii.com/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'http://himasoku.com/', 'https://159.games/', 'https://20.mark.qureka.com/', 'https://312bet2.com/',
      'https://adventofcode.com/', 'https://als.dfbocai.net/', 'https://arabx77.com/', 'https://bet30.click/',
      'https://botdrivea.filesdl.in/', 'https://cashstark.com/', 'https://collective.world/', 'https://crictoday.com/',
      'https://daily.insightposts.com/', 'https://dtruyen.net/', 'https://fansided.com/', 'https://fap-guru.fun/',
      'https://fapello.ru/', 'https://fqa.vn/', 'https://gadget.viva.co.id/', 'https://gol.yalla-shoot-as.com/',
      'https://home89311.com/', 'https://icai.nic.in/', 'https://id.soccerway.com/', 'https://isolatedovercomepasted.com/',
      'https://login.rosettastone.com/', 'https://ludoplayers.com/', 'https://m.24xxx.party/', 'https://m.anwap.love/',
      'https://m.porno666.men/', 'https://m.sek3oeb.com/', 'https://m.tamiltech.live/', 'https://m.topaipick.com/',
      'https://mangathailand.com/', 'https://melbet.com/', 'https://mlookelporno.com/', 'https://modcombo.com/',
      'https://mtg.89k.app/', 'https://nordot.app/', 'https://numberticket.jp/', 'https://nurseryrhymestv.com/',
      'https://pgsgame.online/', 'https://pip.kemdikbud.go.id/', 'https://pogovorim.by/', 'https://point-g.rakuten.co.jp/',
      'https://portal1.passportindia.gov.in/', 'https://portaldopalmeirense.com.br/', 'https://probo.in/', 'https://progorod33.ru/',
      'https://progorod59.ru/', 'https://satta-king.org/', 'https://scorenga.com/', 'https://smakosze.pl/',
      'https://sor-soch.com/', 'https://soydelmillo.com/', 'https://tamil.hindustantimes.com/', 'https://thisav.com/',
      'https://ts30.x3.asia.travian.com/', 'https://ts30.x3.europe.travian.com/', 'https://uaserial.com/', 'https://ujian.unnes.ac.id/',
      'https://ursextube.com/', 'https://vdpro.jp/', 'https://videos-zoofilia.com/', 'https://vip.rusvideos.day/',
      'https://web.tubxporn.com/', 'https://winbuzz.games/', 'https://wsec06.bancogalicia.com.ar/', 'https://www.amigosecreto.com.br/',
      'https://www.arabhulks.com/', 'https://www.betswiz.in/', 'https://www.dailydot.com/', 'https://www.dailyharbour.com/',
      'https://www.elfster.com/', 'https://www.encancha.cl/', 'https://www.grandefratello.mediaset.it/', 'https://www.habersarikirmizi.com/',
      'https://www.infonieve.es/', 'https://www.karlsruhe-insider.de/', 'https://www.mastertheenglish.com/', 'https://www.newsnationtv.com/',
      'https://www.pagalworld.us/', 'https://www.parlons-basket.com/', 'https://www.portablenorthpole.com/', 'https://www.redactie24.be/',
      'https://www.relevo.com/', 'https://www.snitch.co.in/', 'https://www.tbgameloader.com/', 'https://www.uppclonline.com/',
      'https://www.xvcams.com/', 'https://xnxxvids.net/', 'https://xvdesi.org/', 'https://xxx.report/',
      'https://xxxcom.cam/', 'https://y2mate.tube/', 'https://youhdjizz.com/', 'https://zrelki.link/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://54bet4.com/', 'https://api.apidatamaster.in/', 'https://app.ogcom.xyz/', 'https://becasbenitojuarez.net/',
      'https://chromeos.dev/', 'https://csirnetdec2024.ntaonline.in/', 'https://dramacool.bg/', 'https://firhub69.com/',
      'https://ibomma1.com/', 'https://lms.tnsed.com/', 'https://luna89921.com/', 'https://m.tub4exer.com/',
      'https://nanas39812.com/', 'https://paws.community/', 'https://pornhuts.one/', 'https://pro87112.com/',
      'https://ru.fap-guru.fun/', 'https://sexpebune.ro/', 'https://studycafe.in/', 'https://web.ayoba.me/',
      'https://ww.mydesi2.mobi/', 'https://www.54bet1.com/', 'https://www.bayburtpostasi.com.tr/', 'https://www.biglots.com/',
      'https://www.iaagamego.com/', 'https://www.lightnovelworld.co/', 'https://www.motorzoom.it/', 'https://www.naturecaptions.com/',
      'https://www.terra.com/', 'https://zia82522.com/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://adcloudeconomy.com/', 'https://anoboy.icu/', 'https://awsar-dst.in/', 'https://bestanswersforme.com/',
      'https://broadensilkslush.com/', 'https://cxid.info/', 'https://decomytree.com/', 'https://expresswish.co/',
      'https://gameshop.live/', 'https://honghotduongpho.com/', 'https://indviral.com/', 'https://mt1.89k.app/',
      'https://mycard10.com/', 'https://mysticalvoyagesbegin.com/', 'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/',
      'https://on82552.com/', 'https://parimatch1-aviator.com/', 'https://pelotainvernal.com/', 'https://r.dofustream.cloud/',
      'https://ratukediri.com/', 'https://sd1.easyfindanswers.com/', 'https://sd4.bestanswersforme.com/', 'https://sd6.bestanswersforme.com/',
      'https://seneporno.com/', 'https://sexmex.top/', 'https://sport.playauto.cloud/', 'https://sugaroy.com/',
      'https://superbet.com/', 'https://tamilglitz.in/', 'https://technicalranjay.net/', 'https://thechopal.com/',
      'https://ugcnetdec2024.ntaonline.in/', 'https://wechoice.vn/', 'https://win.in-pari-match.com/', 'https://win.pari-matchin.com/',
      'https://www.19fortyfive.com/', 'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lagazzettadiviareggio.it/',
      'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.com/', 'https://www.mnei.fr/', 'https://www.myjobalarm.com/',
      'https://www.ncccc.in/', 'https://www.noradsanta.org/', 'https://www.nuitfrance.fr/', 'https://www.seneporno.com/',
      'https://www.thebay.com/', 'https://www.vendeeglobe.org/', 'https://www.vonews.fr/', 'https://youpornxxxx.com/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://betterbe.co/', 'https://buzzhubspot.com/', 'https://checkout-pk.karo-pay.com/', 'https://damangame.chat/',
      'https://hollywoodbets.hubtech.live/', 'https://indiawishes.co/', 'https://pay.upi-pays.com/', 'https://sd1.bestanswersforme.com/',
      'https://sd11.fastanswershere.com/', 'https://technicalranjay.co/', 'https://www.alanyahaber.com/', 'https://www.casinozeus10.com/',
      'https://www.lesdechargeurs.fr/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://blogherald.com/', 'https://chemicalssmuglyuntying.com/', 'https://cryptonews-24.com/',
      'https://filmjepang.viralterbaru.wiki/', 'https://gazetki.kaufino.com/', 'https://getmyapp.store/', 'https://moviesda.page/',
      'https://quaanhdaocuteo.xyz/', 'https://sattaking-up.com/', 'https://tataexchange.in/', 'https://topushh.com/',
      'https://truyenfull.tv/', 'https://zip-fast-plus.com/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://anlatilaninotesi.com.tr/', 'https://app.gradient.network/', 'https://contoseroticoscnn.com/', 'https://cw.x2.international.travian.com/',
      'https://entretenimento.r7.com/', 'https://fqa.vn/', 'https://i.pl/', 'https://javidol.org/',
      'https://katmoviehd.nexus/', 'https://linkintime.co.in/', 'https://mall.bookcapital.com.my/', 'https://missav.com/',
      'https://pathofexile2.com/', 'https://portal2.passportindia.gov.in/', 'https://santatracker.google.com/', 'https://sga.uteq.edu.ec/',
      'https://smutr.com/', 'https://sprunkin.com/', 'https://store.ankama.com/', 'https://www.1337xxx.to/',
      'https://www.crhoy.com/', 'https://www.cuevana.is/', 'https://www.dofus.com/', 'https://www.encancha.cl/',
      'https://www.fingerhut.com/', 'https://www.forever21.com/', 'https://www.insertlive.com/', 'https://www.letmejerk.com/',
      'https://www.marvelrivals.com/', 'https://www.stylevamp.de/', 'https://www.sveedy.com/', 'https://www.svenskdam.se/',
      'https://www.tatd.in/', 'https://www.tv100.com/', 'https://www.unilad.com/', 'https://www.xnxx.fit/',
      'https://zhidao.baidu.com/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'http://himasoku.com/', 'https://activebeat.com/', 'https://adventofcode.com/', 'https://becasbenitojuarez.net/',
      'https://dramacool.bg/', 'https://drawnames.app/', 'https://dtruyen.net/', 'https://fansided.com/',
      'https://fapnfuck.com/', 'https://ga-gcps-psv.edupoint.com/', 'https://icai.nic.in/', 'https://id.soccerway.com/',
      'https://login.rosettastone.com/', 'https://m.anwap.love/', 'https://mahe.gov.in/', 'https://mangathailand.com/',
      'https://melbet.com/', 'https://newautopost.co.kr/', 'https://pinterestdownloader.com/', 'https://pip.kemdikbud.go.id/',
      'https://portal1.passportindia.gov.in/', 'https://quiz-facts.com/', 'https://scorenga.com/', 'https://shownews.pl/',
      'https://snowmtl.ru/', 'https://super.walmart.com.mx/', 'https://th.xhopen.com/', 'https://tiger365.me/',
      'https://vdpro.jp/', 'https://vip.rusvideos.day/', 'https://www.dailydot.com/', 'https://www.dailynayadiganta.com/',
      'https://www.dsij.in/', 'https://www.infonieve.es/', 'https://www.pagalworld.us/', 'https://www.portablenorthpole.com/',
      'https://www.relevo.com/', 'https://www.trackwrestling.com/', 'https://www.trainman.in/', 'https://www.uppclonline.com/',
      'https://www.xvcams.com/', 'https://y2mate.tube/', 'https://zrelki.link/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://csirnetdec2024.ntaonline.in/', 'https://lms.tnsed.com/', 'https://nordot.app/', 'https://point-g.rakuten.co.jp/',
      'https://thisav.com/', 'https://www.aocrecruitment.gov.in/', 'https://www.biglots.com/', 'https://www.mastertheenglish.com/',
      'https://www.naturecaptions.com/', 'https://www.snitch.co.in/', 'https://www.vendeeglobe.org/', 'https://www.y2mate.com/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://decomytree.com/', 'https://firhub69.com/', 'https://gsa.teletalk.com.bd/', 'https://ibomma1.com/',
      'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/', 'https://pornhuts.one/', 'https://r.dofustream.cloud/',
      'https://sexmex.top/', 'https://sexpebune.ro/', 'https://ugcnetdec2024.ntaonline.in/', 'https://wechoice.vn/',
      'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.co/',
      'https://www.lightnovelworld.com/', 'https://www.noradsanta.org/', 'https://www.thebay.com/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://cdromance.org/', 'https://cryptonews-24.com/', 'https://dramacool.com.tr/', 'https://quaanhdaocuteo.xyz/',
      'https://superbet.com/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://getmyapp.store/', 'https://torrentgalaxy.to/', 'https://truyenfull.tv/',
      'https://www.gtainside.com/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://11xplay.pro/', 'https://anlatilaninotesi.com.tr/', 'https://app.gradient.network/', 'https://catracalivre.com.br/',
      'https://collective.world/', 'https://contoseroticoscnn.com/', 'https://cw.x2.international.travian.com/', 'https://daily.insightposts.com/',
      'https://entretenimento.r7.com/', 'https://fqa.vn/', 'https://govdotin.com/', 'https://hackerdoslot2.com/',
      'https://i.pl/', 'https://in3xnet.com/', 'https://javidol.org/', 'https://katmoviehd.nexus/',
      'https://laser247.club/', 'https://linkintime.co.in/', 'https://m.dfbocai.net/', 'https://m.porno666.moe/',
      'https://m.porno666.org/', 'https://mall.bookcapital.com.my/', 'https://missav.com/', 'https://nyess.co.id/',
      'https://pathofexile2.com/', 'https://portal2.passportindia.gov.in/', 'https://portaldopalmeirense.com.br/', 'https://progorodsamara.ru/',
      'https://ratemysoft.com/', 'https://sangelink.com.de/', 'https://santatracker.google.com/', 'https://satta-king.org/',
      'https://seucreditodigital.com.br/', 'https://sga.uteq.edu.ec/', 'https://smutr.com/', 'https://spilleddaily.com/',
      'https://sprunkin.com/', 'https://store.ankama.com/', 'https://txxx.tube/', 'https://vidmateapp.tools/',
      'https://www.1337xxx.to/', 'https://www.baji999.in/', 'https://www.bet30pro.com/', 'https://www.crhoy.com/',
      'https://www.cuevana.is/', 'https://www.dofus.com/', 'https://www.dotyk.cz/', 'https://www.encancha.cl/',
      'https://www.energycue.it/', 'https://www.fingerhut.com/', 'https://www.forever21.com/', 'https://www.getsurrey.co.uk/',
      'https://www.ibahia.com/', 'https://www.insertlive.com/', 'https://www.letmejerk.com/', 'https://www.marvelrivals.com/',
      'https://www.parlons-basket.com/', 'https://www.reddybook.club/', 'https://www.shownieuws.nl/', 'https://www.stylevamp.de/',
      'https://www.sveedy.com/', 'https://www.svenskdam.se/', 'https://www.tatd.in/', 'https://www.thehealthsite.com/',
      'https://www.tv100.com/', 'https://www.unilad.com/', 'https://www.xnxx.fit/', 'https://xzx.mobi/',
      'https://zhidao.baidu.com/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'http://himasoku.com/', 'https://20.mark.qureka.com/', 'https://312bet2.com/', 'https://a7-satta.com/',
      'https://activebeat.com/', 'https://adventofcode.com/', 'https://api.apidatamaster.in/', 'https://app.ogcom.xyz/',
      'https://arabx77.com/', 'https://becasbenitojuarez.net/', 'https://bet30.click/', 'https://botdrivea.filesdl.in/',
      'https://cashstark.com/', 'https://community.truecaller.com/', 'https://crictoday.com/', 'https://desipapa.watch/',
      'https://dramacool.bg/', 'https://dtruyen.net/', 'https://fakti.online/', 'https://fansided.com/',
      'https://fap-guru.fun/', 'https://fapnfuck.com/', 'https://ga-gcps-psv.edupoint.com/', 'https://gadget.viva.co.id/',
      'https://icai.nic.in/', 'https://id.soccerway.com/', 'https://isolatedovercomepasted.com/', 'https://login.rosettastone.com/',
      'https://ludoplayers.com/', 'https://m.anwap.love/', 'https://m.porno666.men/', 'https://m.sek3oeb.com/',
      'https://m.tamiltech.live/', 'https://m.topaipick.com/', 'https://mahe.gov.in/', 'https://mangathailand.com/',
      'https://melbet.com/', 'https://mlookelporno.com/', 'https://modcombo.com/', 'https://mtg.89k.app/',
      'https://my-wishes.co/', 'https://newautopost.co.kr/', 'https://numberticket.jp/', 'https://pgsgame.online/',
      'https://pinterestdownloader.com/', 'https://pip.kemdikbud.go.id/', 'https://portal1.passportindia.gov.in/', 'https://probo.in/',
      'https://quiz-facts.com/', 'https://scorenga.com/', 'https://shownews.pl/', 'https://smakosze.pl/',
      'https://snowmtl.ru/', 'https://super.walmart.com.mx/', 'https://tamil.hindustantimes.com/', 'https://th.xhopen.com/',
      'https://tiger365.me/', 'https://vdpro.jp/', 'https://videos-zoofilia.com/', 'https://vip.rusvideos.day/',
      'https://vologda-poisk.ru/', 'https://winbuzz.games/', 'https://www.arabhulks.com/', 'https://www.betswiz.in/',
      'https://www.bugetul.ro/', 'https://www.dailydot.com/', 'https://www.dailyharbour.com/', 'https://www.dailynayadiganta.com/',
      'https://www.dsij.in/', 'https://www.foxsports.com.mx/', 'https://www.gaveanews.com/', 'https://www.habersarikirmizi.com/',
      'https://www.infonieve.es/', 'https://www.karlsruhe-insider.de/', 'https://www.metroworldnews.com.br/', 'https://www.newsnationtv.com/',
      'https://www.okmag.gr/', 'https://www.pagalworld.us/', 'https://www.portablenorthpole.com/', 'https://www.redactie24.be/',
      'https://www.relevo.com/', 'https://www.tbgameloader.com/', 'https://www.thueringen24.de/', 'https://www.trackwrestling.com/',
      'https://www.trainman.in/', 'https://www.uppclonline.com/', 'https://www.xvcams.com/', 'https://xnxxvids.net/',
      'https://xvdesi.org/', 'https://xxx.report/', 'https://xxxcom.cam/', 'https://y2mate.tube/',
      'https://youhdjizz.com/', 'https://zrelki.link/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://54bet4.com/', 'https://chromeos.dev/', 'https://csirnetdec2024.ntaonline.in/', 'https://lms.tnsed.com/',
      'https://m.tub4exer.com/', 'https://nanas39812.com/', 'https://nordot.app/', 'https://paws.community/',
      'https://point-g.rakuten.co.jp/', 'https://studycafe.in/', 'https://techsvet.cz/', 'https://thisav.com/',
      'https://ursextube.com/', 'https://vip.24xxx.party/', 'https://web.ayoba.me/', 'https://www.19fortyfive.com/',
      'https://www.54bet1.com/', 'https://www.bayburtpostasi.com.tr/', 'https://www.biglots.com/', 'https://www.mastertheenglish.com/',
      'https://www.naturecaptions.com/', 'https://www.nesiatimes.com/', 'https://www.snitch.co.in/', 'https://www.terra.com/',
      'https://www.vendeeglobe.org/', 'https://www.y2mate.com/', 'https://zia82522.com/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://adcloudeconomy.com/', 'https://bestanswersforme.com/', 'https://broadensilkslush.com/', 'https://cricbet99.club/',
      'https://cxid.info/', 'https://decomytree.com/', 'https://expresswish.co/', 'https://firhub69.com/',
      'https://gsa.teletalk.com.bd/', 'https://ibomma1.com/', 'https://indviral.com/', 'https://m.24xxx.party/',
      'https://mycard10.com/', 'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/', 'https://newsy.almesasports.com/',
      'https://pornhuts.one/', 'https://progorod59.ru/', 'https://r.dofustream.cloud/', 'https://ru.fap-guru.fun/',
      'https://seneporno.com/', 'https://sexmex.top/', 'https://soydelmillo.com/', 'https://sport.playauto.cloud/',
      'https://sports.kkxxtt.com/', 'https://sugaroy.com/', 'https://thechopal.com/', 'https://ugcnetdec2024.ntaonline.in/',
      'https://wechoice.vn/', 'https://win.in-pari-match.com/', 'https://win.pari-matchin.com/', 'https://ww.mydesi2.mobi/',
      'https://www.iaagamego.com/', 'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lagazzettadiviareggio.it/',
      'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.co/', 'https://www.lightnovelworld.com/', 'https://www.mnei.fr/',
      'https://www.motorzoom.it/', 'https://www.ncccc.in/', 'https://www.noradsanta.org/', 'https://www.nuitfrance.fr/',
      'https://www.seneporno.com/', 'https://www.thebay.com/', 'https://www.vonews.fr/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://betterbe.co/', 'https://cdromance.org/', 'https://checkout-pk.karo-pay.com/', 'https://cryptonews-24.com/',
      'https://dramacool.com.tr/', 'https://gameshop.live/', 'https://hollywoodbets.hubtech.live/', 'https://indiawishes.co/',
      'https://moviesda.page/', 'https://mt1.89k.app/', 'https://parimatch1-aviator.com/', 'https://quaanhdaocuteo.xyz/',
      'https://sports.nnppffccddggdd.com/', 'https://superbet.com/', 'https://technicalranjay.net/', 'https://www.casinozeus10.com/',
      'https://www.lesdechargeurs.fr/', 'https://www.myjobalarm.com/', 'https://xmaza.co/', 'https://youpornxxxx.com/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://affluentarmyequator.com/', 'https://blogherald.com/', 'https://buzzhubspot.com/', 'https://filmjepang.viralterbaru.wiki/',
      'https://getmyapp.store/', 'https://pay.upi-pays.com/', 'https://sd11.fastanswershere.com/', 'https://technicalranjay.co/',
      'https://truyenfull.tv/', 'https://www.alanyahaber.com/', 'https://www.gtainside.com/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 100000 AND page IN (
      'https://activebeat.com/', 'https://adventofcode.com/', 'https://anlatilaninotesi.com.tr/', 'https://contoseroticoscnn.com/',
      'https://entretenimento.r7.com/', 'https://fandomwire.com/', 'https://istoe.com.br/', 'https://javidol.org/',
      'https://kinogo.fm/', 'https://linkintime.co.in/', 'https://mangareader.to/', 'https://missav.com/',
      'https://portal2.passportindia.gov.in/', 'https://say.games/', 'https://smutr.com/', 'https://sprunkin.com/',
      'https://ugcnet.nta.ac.in/', 'https://ujian.unnes.ac.id/', 'https://urdu.geo.tv/', 'https://web.vk.me/',
      'https://www.1337xxx.to/', 'https://www.becaritacetina.gob.mx/', 'https://www.cuevana.is/', 'https://www.encancha.cl/',
      'https://www.fingerhut.com/', 'https://www.forever21.com/', 'https://www.gercekgundem.com/', 'https://www.insertlive.com/',
      'https://www.investireoggi.it/', 'https://www.letmejerk.com/', 'https://www.marvelrivals.com/', 'https://www.mastertheenglish.com/',
      'https://www.prokabaddi.com/', 'https://www.redd.tube/', 'https://www.stylevamp.de/', 'https://www.svenskdam.se/',
      'https://www.tatd.in/', 'https://www.themirror.com/', 'https://www.unilad.com/', 'https://zhidao.baidu.com/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 500000 AND page IN (
      'http://himasoku.com/', 'https://app.gradient.network/', 'https://comick.io/', 'https://decomytree.com/',
      'https://dtruyen.net/', 'https://fansided.com/', 'https://fapnfuck.com/', 'https://fqa.vn/',
      'https://ga-gcps-psv.edupoint.com/', 'https://id.soccerway.com/', 'https://katmoviehd.nexus/', 'https://login.rosettastone.com/',
      'https://m.anwap.love/', 'https://mahe.gov.in/', 'https://mall.bookcapital.com.my/', 'https://mangathailand.com/',
      'https://melbet.com/', 'https://newautopost.co.kr/', 'https://newtoki.biz/', 'https://pathofexile2.com/',
      'https://pinterestdownloader.com/', 'https://pip.kemdikbud.go.id/', 'https://portal1.passportindia.gov.in/', 'https://quiz-facts.com/',
      'https://ris.kfintech.com/', 'https://scorenga.com/', 'https://shownews.pl/', 'https://snowmtl.ru/',
      'https://th.xhopen.com/', 'https://vdpro.jp/', 'https://vip.rusvideos.day/', 'https://www.aldiventskalender.de/',
      'https://www.crhoy.com/', 'https://www.dailydot.com/', 'https://www.dailynayadiganta.com/', 'https://www.noradsanta.org/',
      'https://www.pagalworld.us/', 'https://www.relevo.com/', 'https://www.snitch.co.in/', 'https://www.sveedy.com/',
      'https://www.trainman.in/', 'https://www.tv100.com/', 'https://www.uppclonline.com/', 'https://www.xnxx.fit/',
      'https://www.xvcams.com/', 'https://y2mate.tube/', 'https://zrelki.link/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 1000000 AND page IN (
      'https://cw.x2.international.travian.com/', 'https://lms.tnsed.com/', 'https://nordot.app/', 'https://point-g.rakuten.co.jp/',
      'https://thisav.com/', 'https://www.aocrecruitment.gov.in/', 'https://www.biglots.com/', 'https://www.dsij.in/',
      'https://www.y2mate.com/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 5000000 AND page IN (
      'https://anime-indy.com/', 'https://becasbenitojuarez.net/', 'https://blaze.com/', 'https://csirnetdec2024.ntaonline.in/',
      'https://firhub69.com/', 'https://gol.yalla-shoot-as.com/', 'https://kr72.sogirl.so/', 'https://lokapai.ppgkemenag.com/',
      'https://mangaonline.blog/', 'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/', 'https://prospekte.kaufino.com/',
      'https://sexmex.top/', 'https://thecuckold.com/', 'https://torrent9.to/', 'https://ugcnetdec2024.ntaonline.in/',
      'https://wechoice.vn/', 'https://www.ibomma.co.in/', 'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/',
      'https://www.lightnovelworld.co/', 'https://www.lightnovelworld.com/', 'https://www.naturecaptions.com/', 'https://www.thebay.com/',
      'https://www.vendeeglobe.org/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 10000000 AND page IN (
      'https://innovateindia1.mygov.in/', 'https://nurseryrhymestv.com/', 'https://r.dofustream.cloud/', 'https://superbet.com/',
      'https://tvroom5.org/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 50000000 AND page IN (
      'https://boxnovel.com/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 100000 AND page IN (
      'https://11xplay.pro/', 'https://activebeat.com/', 'https://adventofcode.com/', 'https://allpanelexch.com/',
      'https://anlatilaninotesi.com.tr/', 'https://brasil.perfil.com/', 'https://contoseroticoscnn.com/', 'https://daily.insightposts.com/',
      'https://econmingle.com/', 'https://economy.okezone.com/', 'https://entretenimento.r7.com/', 'https://fandomwire.com/',
      'https://food.topicbee.net/', 'https://free.apkzonic.com/', 'https://govdotin.com/', 'https://id.xhing.xyz/',
      'https://in3xnet.com/', 'https://istoe.com.br/', 'https://javidol.org/', 'https://kinogo.fm/',
      'https://laser247.club/', 'https://linkintime.co.in/', 'https://m.dfbocai.net/', 'https://m.porno666.moe/',
      'https://m.porno666.org/', 'https://m.trend-tech.net/', 'https://mangareader.to/', 'https://missav.com/',
      'https://mxseries.com.co/', 'https://numberticket.jp/', 'https://ohbulan.com/', 'https://portaldopalmeirense.com.br/',
      'https://progorodsamara.ru/', 'https://say.games/', 'https://seucreditodigital.com.br/', 'https://sexvideos.rodeo/',
      'https://smutr.com/', 'https://sprunkin.com/', 'https://travel.topicbee.net/', 'https://txxx.tube/',
      'https://ugcnet.nta.ac.in/', 'https://ujian.unnes.ac.id/', 'https://urdu.geo.tv/', 'https://vidmateapp.tools/',
      'https://web.vk.me/', 'https://www.1337xxx.to/', 'https://www.baji999.in/', 'https://www.becaritacetina.gob.mx/',
      'https://www.cuevana.is/', 'https://www.dotyk.cz/', 'https://www.encancha.cl/', 'https://www.fingerhut.com/',
      'https://www.forever21.com/', 'https://www.foxsports.com.mx/', 'https://www.gercekgundem.com/', 'https://www.getsurrey.co.uk/',
      'https://www.insertlive.com/', 'https://www.investireoggi.it/', 'https://www.letmejerk.com/', 'https://www.marvelrivals.com/',
      'https://www.mastertheenglish.com/', 'https://www.okmag.gr/', 'https://www.prokabaddi.com/', 'https://www.radheexch.xyz/',
      'https://www.redd.tube/', 'https://www.shownieuws.nl/', 'https://www.stylevamp.de/', 'https://www.svenskdam.se/',
      'https://www.tatd.in/', 'https://www.thehealthsite.com/', 'https://www.unilad.com/', 'https://www.zupee.com/',
      'https://xmaza.co/', 'https://yakutiamedia.ru/', 'https://zhidao.baidu.com/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 500000 AND page IN (
      'http://himasoku.com/', 'https://20.mark.qureka.com/', 'https://a7-satta.com/', 'https://api.apidatamaster.in/',
      'https://app.gradient.network/', 'https://app.ogcom.xyz/', 'https://bet30.click/', 'https://botdrivea.filesdl.in/',
      'https://cashstark.com/', 'https://comick.io/', 'https://community.truecaller.com/', 'https://cricbet99.club/',
      'https://crictoday.com/', 'https://decomytree.com/', 'https://desipapa.watch/', 'https://dtruyen.net/',
      'https://fakti.online/', 'https://fansided.com/', 'https://fap-guru.fun/', 'https://fapnfuck.com/',
      'https://fqa.vn/', 'https://ga-gcps-psv.edupoint.com/', 'https://gadget.viva.co.id/', 'https://id.soccerway.com/',
      'https://isolatedovercomepasted.com/', 'https://katmoviehd.nexus/', 'https://login.rosettastone.com/', 'https://ludoplayers.com/',
      'https://m.anwap.love/', 'https://m.tamiltech.live/', 'https://m.topaipick.com/', 'https://mahe.gov.in/',
      'https://mall.bookcapital.com.my/', 'https://mangathailand.com/', 'https://melbet.com/', 'https://mlookelporno.com/',
      'https://newautopost.co.kr/', 'https://newsfirstlive.com/', 'https://newtoki.biz/', 'https://pathofexile2.com/',
      'https://pinterestdownloader.com/', 'https://pip.kemdikbud.go.id/', 'https://portal1.passportindia.gov.in/', 'https://probo.in/',
      'https://quiz-facts.com/', 'https://ratemysoft.com/', 'https://ris.kfintech.com/', 'https://scorenga.com/',
      'https://shownews.pl/', 'https://snowmtl.ru/', 'https://soydelmillo.com/', 'https://spilleddaily.com/',
      'https://studycafe.in/', 'https://techsvet.cz/', 'https://th.xhopen.com/', 'https://vdpro.jp/',
      'https://videos-zoofilia.com/', 'https://vip.rusvideos.day/', 'https://vologda-poisk.ru/', 'https://www.aldiventskalender.de/',
      'https://www.arabhulks.com/', 'https://www.bugetul.ro/', 'https://www.crhoy.com/', 'https://www.dailydot.com/',
      'https://www.dailynayadiganta.com/', 'https://www.energycue.it/', 'https://www.expertsfaq.com/', 'https://www.gaveanews.com/',
      'https://www.habersarikirmizi.com/', 'https://www.ibahia.com/', 'https://www.newsnationtv.com/', 'https://www.noradsanta.org/',
      'https://www.pagalworld.us/', 'https://www.redactie24.be/', 'https://www.relevo.com/', 'https://www.snitch.co.in/',
      'https://www.sveedy.com/', 'https://www.tbgameloader.com/', 'https://www.thueringen24.de/', 'https://www.trainman.in/',
      'https://www.tv100.com/', 'https://www.uppclonline.com/', 'https://www.xn--82cx3h8b.live/', 'https://www.xnxx.fit/',
      'https://www.xvcams.com/', 'https://xnxxvids.net/', 'https://xvdesi.org/', 'https://xxx.report/',
      'https://xxxcom.cam/', 'https://y2mate.tube/', 'https://zrelki.link/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 1000000 AND page IN (
      'https://312bet2.com/', 'https://54bet4.com/', 'https://chromeos.dev/', 'https://cw.x2.international.travian.com/',
      'https://indviral.com/', 'https://lms.tnsed.com/', 'https://m.porno666.men/', 'https://m.sek3oeb.com/',
      'https://my-wishes.co/', 'https://nordot.app/', 'https://paws.community/', 'https://pgsgame.online/',
      'https://point-g.rakuten.co.jp/', 'https://sugaroy.com/', 'https://tamil.hindustantimes.com/', 'https://thisav.com/',
      'https://www.54bet1.com/', 'https://www.bayburtpostasi.com.tr/', 'https://www.betswiz.in/', 'https://www.biglots.com/',
      'https://www.dailyharbour.com/', 'https://www.dsij.in/', 'https://www.karlsruhe-insider.de/', 'https://www.reddybook.live/',
      'https://www.terra.com/', 'https://www.y2mate.com/', 'https://xhexperience.xyz/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 5000000 AND page IN (
      'https://ara.xhexperience.xyz/', 'https://becasbenitojuarez.net/', 'https://csirnetdec2024.ntaonline.in/', 'https://cxid.info/',
      'https://expresswish.co/', 'https://firhub69.com/', 'https://gol.yalla-shoot-as.com/', 'https://indiawishes.co/',
      'https://kr72.sogirl.so/', 'https://lokapai.ppgkemenag.com/', 'https://m.24xxx.party/', 'https://m.tub4exer.com/',
      'https://mangaonline.blog/', 'https://mycard10.com/', 'https://nakarmpsa.olx.pl/', 'https://news.biglobe.ne.jp/',
      'https://news102.ru/', 'https://newsy.almesasports.com/', 'https://progorod59.ru/', 'https://prospekte.kaufino.com/',
      'https://ru.fap-guru.fun/', 'https://seneporno.com/', 'https://sexmex.top/', 'https://sport.playauto.cloud/',
      'https://sports.kkxxtt.com/', 'https://thechopal.com/', 'https://thecuckold.com/', 'https://torrent9.to/',
      'https://ugcnetdec2024.ntaonline.in/', 'https://ursextube.com/', 'https://vip.24xxx.party/', 'https://web.ayoba.me/',
      'https://wechoice.vn/', 'https://win.pari-matchin.com/', 'https://www.iaagamego.com/', 'https://www.ibomma.co.in/',
      'https://www.karmasandhan.com/', 'https://www.lightnovelpub.com/', 'https://www.lightnovelworld.co/', 'https://www.lightnovelworld.com/',
      'https://www.mnei.fr/', 'https://www.motorzoom.it/', 'https://www.naturecaptions.com/', 'https://www.ncccc.in/',
      'https://www.nesiatimes.com/', 'https://www.nuitfrance.fr/', 'https://www.seneporno.com/', 'https://www.thebay.com/',
      'https://www.vendeeglobe.org/', 'https://www.vonews.fr/', 'https://zia82522.com/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 10000000 AND page IN (
      'https://awsar-dst.in/', 'https://bestanswersforme.com/', 'https://betterbe.co/', 'https://broadensilkslush.com/',
      'https://castleapps.org/', 'https://innovateindia1.mygov.in/', 'https://iq.iqraa.news/', 'https://lagradaonline.com/',
      'https://mtg.89k.app/', 'https://nurseryrhymestv.com/', 'https://parimatch1-aviator.com/', 'https://r.dofustream.cloud/',
      'https://sd11.fastanswershere.com/', 'https://superbet.com/', 'https://technicalranjay.net/', 'https://tvroom5.org/',
      'https://win.in-pari-match.com/', 'https://www.lagazzettadiviareggio.it/', 'https://www.myjobalarm.com/', 'https://youpornxxxx.com/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 50000000 AND page IN (
      'https://blogherald.com/', 'https://boxnovel.com/', 'https://buzzhubspot.com/', 'https://checkout-pk.karo-pay.com/',
      'https://filmjepang.viralterbaru.wiki/', 'https://gameshop.live/', 'https://getmyapp.store/', 'https://hollywoodbets.hubtech.live/',
      'https://mt1.89k.app/', 'https://pay.upi-pays.com/', 'https://sattamatkaj.com/', 'https://technicalranjay.co/',
      'https://www.alanyahaber.com/', 'https://www.bet300.ws/', 'https://www.lesdechargeurs.fr/'))
  )
