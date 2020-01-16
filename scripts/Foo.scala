object Foo {
  def main(args: Array[String]): Unit = {
    val x = "lit-" + java.util.UUID.nameUUIDFromBytes(args(0).getBytes).toString.replace("-", "")
    println(x)
  }
}
