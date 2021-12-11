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

pub struct GridInfo {
    pub width: usize,
    pub height: usize,
}

lazy_static! {
    static ref NEIGHBOURS_4: Vec<(i8, i8)> = vec![
        (0, -1),
        (1, 0),
        (0, 1),
        (-1, 0),
    ];

    static ref NEIGHBOURS_8: Vec<(i8, i8)> = vec![
        (0, -1),
        (1, -1),
        (1, 0),
        (1, 1),
        (0, 1),
        (-1, 1),
        (-1, 0),
        (-1, -1),
    ];
}

impl GridInfo
{
    pub fn new(width: usize, height: usize) -> GridInfo {
        return GridInfo{ width: width, height: height };
    }

    pub fn coords(&self) -> impl Iterator<Item=(usize, usize)> {
        let h = self.height;
        return (0..self.width).flat_map(move |x| (0..h).map(move |y| (x, y)));
    }

    pub fn neighbours(&self, x: usize, y: usize) -> impl Iterator<Item=(usize, usize)> {
        let w = self.width;
        let h = self.height;
        return NEIGHBOURS_4.iter()
            .map(move |(ox, oy)| (x + *ox as usize, y + *oy as usize))
            .filter(move |(x, y)| *x < w && *y < h);
    }

    pub fn neighbours_diag(&self, x: usize, y: usize) -> impl Iterator<Item=(usize, usize)> {
        let w = self.width;
        let h = self.height;
        return NEIGHBOURS_8.iter()
            .map(move |(ox, oy)| (x + *ox as usize, y + *oy as usize))
            .filter(move |(x, y)| *x < w && *y < h);
    }
}