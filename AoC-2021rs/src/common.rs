#[derive(PartialEq, Eq, Hash)]
pub struct Point {
    pub x : i32,
    pub y : i32
}

impl std::fmt::Display for Point {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{},{}", self.x, self.y)
    }
}

pub struct LineSegment {
    pub from : Point,
    pub to: Point
}

impl std::fmt::Display for LineSegment {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} -> {}", self.from, self.to)
    }
}

// pub struct Grid<'a, T> {
//     width: usize,
//     height: usize,
//     content: &'a Vec<Vec<T>>
// }

// impl<'a, T> Grid<'a, T> {
//     fn from(v: &Vec<Vec<T>>) -> Grid<T> {
//         let height = v.len();
//         let width = if height > 0 { v[0].len() } else { 0 };
//         return Grid{ width: width, height: height, content: v };
//     }

//     fn coords(&self) -> impl Iterator<Item=(usize, usize)> {
//         let h = self.height;
//         return (0..self.width).flat_map(move |x| (0..h).map(move |y| (x, y)));
//     }

//     fn at(&self, x: usize, y: usize) -> &T { &self.content[y][x] }
// }