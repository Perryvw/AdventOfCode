use itertools::Itertools;

use crate::aoc::AocSolution;
use crate::common::GridInfo;

type Image = Vec<Vec<bool>>;

pub struct Day20;

impl AocSolution for Day20 {

    fn data_path(&self) -> &str { "data/day20.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let mut split_inp = input.split("\r\n\r\n");
        let enhancement_algorithm: Vec<bool> = split_inp.next().unwrap().as_bytes().iter()
            .map(|b| *b == b'#')
            .collect();
        let input_image: Image = split_inp.next().unwrap()
            .lines()
            .map(|line| line.as_bytes().iter().map(|b| *b == b'#').collect())
            .collect();

        let enhanced = enhance(&input_image, &enhancement_algorithm, false);
        let enhanced2 = enhance(&enhanced, &enhancement_algorithm, true);

        let p1 = enhanced2.iter().map(|line| line.iter().filter(|p| **p).count()).sum::<usize>();

        let mut img = input_image.clone();

        for i in 0..50 {
            img = enhance(&img, &enhancement_algorithm, i % 2 == 1);
        }

        let p2 = img.iter().map(|line| line.iter().filter(|p| **p).count()).sum::<usize>();

        return (p1.to_string(), p2.to_string())
    }
}

fn enhance(image: &Image, enhancement_algorithm: &Vec<bool>, pad_with: bool) -> Image {
    let padded_image = pad(image, pad_with);
    let mut new_image = padded_image.clone();
    let grid = GridInfo::new(new_image[0].len(), new_image.len());

    let coords_to_visit = grid.coords()
        .filter(|(x, y)| *x > 0 && *x < grid.width - 1 && *y > 0 && *y < grid.height - 1);

    for (x, y) in coords_to_visit {
        let rule = pixel_hash(x, y, &padded_image);
        new_image[y][x] = enhancement_algorithm[rule];
    }

    let border_coords = grid.coords()
        .filter(|(x, y)| *x == 0 || *x == grid.width - 1 || *y == 0 || *y == grid.height -  1);

    for (x, y) in border_coords {
        new_image[y][x] = !pad_with;
    }

    return new_image;
}

fn pixel_hash(x: usize, y: usize, image: &Image) -> usize {
    let mut hash = 0;

    hash += if image[y-1][x-1] { 1 } else { 0 } << 8;
    hash += if image[y-1][x] { 1 } else { 0 } << 7;
    hash += if image[y-1][x+1] { 1 } else { 0 } << 6;
    hash += if image[y][x-1] { 1 } else { 0 } << 5;
    hash += if image[y][x] { 1 } else { 0 } << 4;
    hash += if image[y][x+1] { 1 } else { 0 } << 3;
    hash += if image[y+1][x-1] { 1 } else { 0 } << 2;
    hash += if image[y+1][x] { 1 } else { 0 } << 1;
    hash += if image[y+1][x+1] { 1 } else { 0 } << 0;

    return hash;
}

fn print(image: &Image) {
    for line in image.iter() {
        let line_str = line.iter().map(|v| if *v { "X" } else { "." }).join("");
        println!("{}", line_str);
    }
}

fn pad(image: &Image, pad_with: bool) -> Image {
    let width = image[0].len();

    let mut new_image = vec![
        (0..width + 4).map(|_| pad_with).collect(),
        (0..width + 4).map(|_| pad_with).collect(),
    ];

    for line in image.iter() {
        let mut new_line = vec![pad_with, pad_with];

        new_line.extend(line);

        new_line.push(pad_with);
        new_line.push(pad_with);

        new_image.push(new_line);
    }

    new_image.push((0..width + 4).map(|_| pad_with).collect());
    new_image.push((0..width + 4).map(|_| pad_with).collect());

    return new_image;
}
