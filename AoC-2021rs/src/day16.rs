use crate::aoc::AocSolution;

enum Packet {
    Literal { version: u64, value: u64, length: usize },
    Operator { version: u64, type_id: u64, subpackets: Vec<Packet>, length: usize },
}

pub struct Day16;

impl AocSolution for Day16 {

    fn data_path(&self) -> &str { "data/day16.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let mut bitstream = bits(input);

        let p1 = parse_packet(&mut bitstream);

        return (version_sum(&p1).to_string(), evaluate(&p1).to_string())
    }
}

fn evaluate(packet: &Packet) -> u64 {
    match packet {
        Packet::Literal{ value, .. } => *value,
        Packet::Operator{ type_id, subpackets, .. } => match type_id {
            0 => subpackets.iter().map(evaluate).sum(),
            1 => subpackets.iter().map(evaluate).product(),
            2 => subpackets.iter().map(evaluate).min().unwrap(),
            3 => subpackets.iter().map(evaluate).max().unwrap(),
            5 => if evaluate(&subpackets[0]) > evaluate(&subpackets[1]) { 1 } else { 0 },
            6 => if evaluate(&subpackets[0]) < evaluate(&subpackets[1]) { 1 } else { 0 },
            7 => if evaluate(&subpackets[0]) == evaluate(&subpackets[1]) { 1 } else { 0 },
            _ => panic!("unknown type id {}", type_id)
        }
    }
}

fn parse_packet(bitstream: &mut impl Iterator<Item=u8>) -> Packet {
    let version = read_int(3, bitstream);
    let type_id = read_int(3, bitstream);

    return match type_id {
        4 => parse_literal(version, bitstream),
        _ => parse_operator(version, type_id, bitstream),
    }
}

fn parse_operator(version: u64, type_id: u64, bitstream: &mut impl Iterator<Item=u8>) -> Packet {
    let length_type_id = bitstream.next().unwrap();
    if length_type_id == 0 {
        let mut total_subpacket_length = read_int(15, bitstream) as usize;
        let mut subpackets = vec![];

        while total_subpacket_length > 0 {
            let subpacket = parse_packet(bitstream);
            total_subpacket_length -= packet_length(&subpacket);
            subpackets.push(subpacket);
        }

        return Packet::Operator{ version, type_id, subpackets, length: 22 };
    } else {
        let num_subpackets = read_int(11, bitstream);
        return Packet::Operator{ version, type_id, subpackets: (0..num_subpackets).map(|_| parse_packet(bitstream)).collect(), length: 18 };
    }
}

fn parse_literal(version: u64, bitstream: &mut impl Iterator<Item=u8>) -> Packet {
    let mut result = 0;
    let mut total_length = 11;
    while bitstream.next().unwrap() == 1 {
        result <<= 4;
        let v = read_int(4, bitstream);
        result += v;
        total_length += 5;
    }

    result <<= 4;
    result += read_int(4, bitstream);

    return Packet::Literal{ version, value: result, length: total_length };
}

fn version_sum(packet: &Packet) -> u64 {
    match packet {
        Packet::Literal{ version, .. } => *version,
        Packet::Operator{ version, subpackets, .. } => version + subpackets.iter().map(version_sum).sum::<u64>(),
    }
}

fn packet_length(packet: &Packet) -> usize {
    match packet {
        Packet::Literal{ length, .. } => *length,
        Packet::Operator{ subpackets, length, .. } => *length + subpackets.iter().map(packet_length).sum::<usize>()
    }
}

fn read_int(length: u8, bitstream: &mut impl Iterator<Item=u8>) -> u64 {
    (0..length).map(|i| (1 << (length - 1 - i)) * bitstream.next().unwrap() as u64).sum::<u64>()
}

fn bits<'a>(inp: &'a str) -> impl Iterator<Item=u8> + 'a{
    inp.as_bytes().iter().flat_map(|b| match b {
        (b'0'..=b'9') => num_bits(b - b'0'),
        (b'A'..=b'F') => num_bits(b - b'A' + 10),
        _ => panic!("wup")
    })
}

fn num_bits(v: u8) -> impl Iterator<Item=u8> {
    (0..4).map(move |i| (v >> (3 - i)) % 2)
}
