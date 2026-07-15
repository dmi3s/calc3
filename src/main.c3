module calc3::main;
import std::io;
import calc3::token;


enum State : int {
    WAITING,
    RUNNING,
    TERMINATED,
}

fn void main() {
    State state = WAITING;
    String name = state.description;
    log::info("state.description: String = \"%s\"", name);
    // State.
}
