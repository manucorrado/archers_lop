extends RefCounted
## Hand-pixelled shop emblems. Each texel stays square at every interface scale.

const COLORS := {
	"k": Color("#453d34"), "w": Color("#986947"), "t": Color("#daa46c"),
	"g": Color("#619183"), "s": Color("#98c1a0"), "p": Color("#f4e6bd"),
	"a": Color("#f4bd65"), "c": Color("#c68257"), "r": Color("#df8e79"),
}

const SPRITES := {
	"damage_mult": ["...a.....app", "...p.a..app.", ".a.ap..app..", "..pps.app...", "...p.app...a", "....app...p.", "...tw...ppp.", "..tw...a.p.a", ".tw......p..", "tw...a......", "w....p......", "...appa....."],
	"rate_flat": ["........appp", "....aa..ppp.", "...ap..ppt..", "..ap..pt..ap", ".ap..tw..app", ".a..tw..apt.", "...tw..at..a", "..tw..at..ap", ".tw..at..ap.", "tw..at..at..", "w..at..at...", "..at..at...."],
	"damage": [".........ppp", "........ppsp", ".......ppssp", ".......psss.", "......tts...", ".....tt.....", "....tt......", ".gpww.......", ".ggw........", ".wwgg.......", "tw.pg.......", "t..........."],
	"rate": [".........aaa", ".....gg..taa", "....gssg.at.", "...gssg.ta..", "....gg.ta...", "..sss.ta...a", ".ssg.ta...aa", "..g.ta...at.", "...ta...ta..", "..ta...ta...", ".ta...ta....", "ta...ta....."],
	"weak": ["....wwww....", "..wwttttww..", ".wttppppttw.", ".wtppggpptw.", "wtppgssgpptw", "wtpgsaasgptw", "wtpgsaasgptw", "wtppgssgpptw", ".wtppggpptw.", ".wttppppttw.", "..wwttttww..", "....wwww...."],
	"workshop": ["....pp......", "...wwtw.....", "..wttttw....", ".wttttttww..", "wwwwwwwwwww.", "..tk..wkt...", "..tk..wkt...", "..tttttttt..", "..wggggggw..", "..wtwwttww..", "..wt..tw....", ".www..www..."],
	"refund": [".....sss....", "....sgggss..", "..s.g...ggs.", ".sss.....sg.", "ssssss....g.", ".ssss...aa..", "..ss...attt.", ".......tppat", "...s...taaat", "...gss..ttt.", "....ggsgg...", "......gg...."],
	"recurve": ["........pp..", ".........tw.", "........ttw.", ".......p.tw.", "......p.wt..", ".....p.wg...", "....p.gg....", "...p.tw.....", "..p.tw......", ".pttw.......", ".ww.........", "..pp........"],
	"longbow": [".........taa", ".........tw.", "........ptw.", ".......p.tw.", "......p.tw..", ".....p.gg...", "....p.sg....", "...p.tt.....", "..p.tw......", ".p.tt.......", ".ttw........", "aaw........."],
	"spark": ["......aa....", ".....aap....", "....aapa....", "...aapa.....", "..aapa......", ".aapaaaaa...", "...cccapa...", ".....apa....", "....apa.....", "...apa......", "..aa........", ".a.........."],
	"combo": ["......gggg..", ".....gssspg.", "....gsg..sg.", "....gs..sg..", ".....gssg...", "....aaag....", "...aapa.....", "..taa.at....", ".ta..tat....", ".taatat.....", "..ttat......", "...tt......."],
	"crit": [".....a.....p", ".....a....p.", ".a...aa..p..", "..aa.aa.a...", "...aapa.....", "aaaapppaaaa.", "..acpppaa...", "....cpcaa...", "...ccaca.a..", "..c..ac...a.", ".c....c.....", "............"],
	"steady": ["....tttttt..", "...tw....tw.", "..tk..p...tw", "..tk..p..gtw", "..tk..ppg.tw", "...twgg..tw.", "....wwwwww..", "............", ".ttt.ggg.aaa", "..tt..gg..aa", ".tt..gg..aa.", "............"],
	"wheel": ["....tttt....", "..ttwttwtt..", ".twpttttpwt.", ".t.p.tt.p.t.", "tw..pttp..wt", "tttttaattttt", "tttttaattttt", "tw..pttp..wt", ".t.p.tt.p.t.", ".twpttttpwt.", "..ttwttwtt..", "....tttt...."],
	"capacity": ["......pp..ps", "....p.ps.ppg", "....psg..pg.", ".....t..ts..", "...wwttttt..", "..wttwtwwtw.", "..wsgsssww..", "..wtgggtw...", ".wtttktw....", ".wttwkw.....", ".wwwtw......", "..www......."],
	"pickup": ["........gsps", "......gssspg", "....gsssspg.", "...gsspssg..", "..gsspssg...", "..gspssg....", "..gpssg.....", "..tgg.......", ".t....gggg..", "t....gssg...", "....gssg....", "...ggg......"],
	"pace": [".......ttt..", "......wttw..", ".....wwttw..", ".....wgtgw..", ".....wgggw..", "....wttttw..", "..wttttwwt..", ".wttttwkkt..", ".wwwwwkkkk..", "............", "...ggggg....", ".ggg........"],
	"leap": [".......aaaa.", ".....aaa.ap.", "....aa..ap..", "...aa..ap...", "..aa........", ".aa....ps.pg", ".a.....st.ps", ".......tgtg.", "......gssgg.", "......ttww..", ".....twtt...", ".....tww...."],
	"pet": ["..tt....tt..", "..twt..twt..", "..twwwwwtt..", "..wttttttw..", ".wttttttttw.", ".wtkttttktw.", ".wtttwwtttw.", "..wtwkkwtw..", "...ttkktw...", "...wppppw...", "..wwtppwww..", "..ttwwwwtt.."],
}

static var cache: Dictionary = {}

static func texture(id: String) -> Texture2D:
	var symbol := id
	if id.contains("_step_"):
		symbol = id.get_slice("_step_", 0)
	if not cache.has(symbol):
		var sprite: Array = SPRITES[symbol]
		var pixels := Image.create_empty(12, 12, false, Image.FORMAT_RGBA8)
		for y in sprite.size():
			for x in sprite[y].length():
				var key: String = sprite[y][x]
				if COLORS.has(key):
					pixels.set_pixel(x, y, COLORS[key])
		cache[symbol] = ImageTexture.create_from_image(pixels)
	return cache[symbol]
