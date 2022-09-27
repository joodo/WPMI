import sys
import re
import json


def foo():
    str = "__main__"
    print(str)


if __name__ == "__main__":
    fo = open(sys.argv[1], "r")
    s = fo.read()
    fo.close()

    s = re.findall(r"[{](.*)[}]", s, re.S)[0]
    s = s.splitlines()

    colorprefix = "--md-sys-color-"
    lightsuffix = "-light"
    darksuffix = "-dark"
    colorLight = {}
    colorDark = {}

    fontprefix = "--md-sys-typescale-"

    font = {}
    lineheight = {}
    fontweight = {"400px": 50, "500px": 57}

    for i in s:
        i = i.replace(" ", "").replace(";", "")
        if (i.startswith(colorprefix)):
            i = i[len(colorprefix):]
            key, value = i.split(":")
            if key.endswith(darksuffix):
                colorDark[key[:-len(darksuffix)]] = value
                # print((re.sub(r"(_|-)+", " ", key[:-len(darksuffix)])).title().replace(" ", "")+",")
            if key.endswith(lightsuffix):
                colorLight[key[:-len(lightsuffix)]] = value
                #print("0x"+value[1:]+",  // "+key)
        if (i.startswith(fontprefix)):
            i = i[len(fontprefix):]
            key, value = i.split(":")
            role = "-".join(key.split("-")[:2])
            if role not in font:
                font[role] = {}
            prop = key[len(role) + 1:]

            if prop == "font-family-name":
                # font[role]["family"] = value
                # print((re.sub(r"(_|-)+", " ", role)).title().replace(" ", "")+",")
                pass
            elif prop == "font-family-style":
                pass
            elif prop == "font-weight":
                font[role]["weight"] = fontweight[value]
            elif prop == "font-size":
                font[role]["pointSize"] = float(value[:-2])
            elif prop == "letter-spacing":
                font[role]["letterSpacing"] = float(value[:-2])
            elif prop == "line-height":
                lineheight[role] = round(
                    float(value[:-2]) / font[role]["pointSize"], 2)
            else:
                pass

    fo = open("color.js", "w")
    fo.write(".pragma library\n\n")
    fo.write("const colorLight = %s\n\n" % json.dumps(colorLight, indent=4))
    fo.write("const colorDark = %s\n" % json.dumps(colorDark, indent=4))
    fo.close()

    fo = open("font.json", "w")
    fo.write("({\n")
    for role in font:
        fo.write("\"%s\": Qt.font(%s),\n" % (role, json.dumps(font[role])))
    fo.write("})\n")
    fo.write("(%s)\n" % json.dumps(lineheight, indent=4))
    fo.close()

    for i in lineheight:
        pass
        #print(str(lineheight[i]) + ",  // " + i)
