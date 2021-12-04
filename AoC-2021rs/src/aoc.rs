pub trait AocSolution {
    fn data_path(&self) -> &str;
    fn calculate(&self, input: &String) -> (String, String);
}