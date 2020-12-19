import { isBetween, readData } from "./common";

const passports = readData("data/day4.data").split("\n\n");

// Part 1
const props = ["byr:", "iyr:", "eyr:", "hgt:", "hcl:", "ecl:", "pid:", /*"cid:"*/];
function isValid(passport: string) {
    const matches = passport.match(/(\w{3}):/g);
    return props.every(p => matches!.includes(p));
}

const result = passports.filter(isValid).length;
console.log("Part 1:", result);

// Part 2
function findValue(str: string, key: string) {
    const match = str.match(`${key}:(\\S+)`);
    return match ? match[1] : undefined;
}
function validateNumStr(numStr: string | undefined, digits: number, min: number, max: number) {
    return (numStr === undefined) ? false
        : (numStr.length !== digits) ? false
        : isBetween(parseInt(numStr), min, max) ? true
        : false;
}
function validateHeight(str: string | undefined) {
    if (str === undefined) return false;

    const val = parseInt(str.slice(0, -2));
    return str === undefined ? false
        : ( (str.endsWith("cm") && isBetween(val, 150, 193)) || ( str.endsWith("in") && isBetween(val, 59, 76) ));
}
function validateColor(str: string | undefined) {
    if (str === undefined) return false;
    return str.length === 7 && str[0] === "#" && str.slice(1).match("[0-9a-f]{6}");
}
function validatePid(str: string | undefined) {
    if (str === undefined) return false;
    return str.length === 9 && str.match(/\d{9}/);
}
function isValidStrict(passport: string) {
    return validateNumStr(findValue(passport, "byr"), 4, 1920, 2002)
        && validateNumStr(findValue(passport, "iyr"), 4, 2010, 2020)
        && validateNumStr(findValue(passport, "eyr"), 4, 2020, 2030)
        && validateHeight(findValue(passport, "hgt"))
        && validateColor(findValue(passport, "hcl"))
        && ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].includes(findValue(passport, "ecl")!)
        && validatePid(findValue(passport, "pid"));
}

//console.log(passports.slice(20).filter(isValidStrict));
const result2 = passports.filter(isValidStrict).length;
console.log("Part 2:", result2);