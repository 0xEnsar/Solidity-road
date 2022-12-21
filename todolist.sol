// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract TodoList {

    struct Todo {
        string text;
        bool isCompleted;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo({
            text: _text,
            isCompleted: false
        }));
    }

    function updateText(string calldata _text, uint index) external {
        todos[index].text = _text;
    }

    function get(uint index) public view returns(string memory text, bool isComplated) {
        Todo storage todo = todos[index];
        return(todo.text, todo.isCompleted);
    }

    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.isCompleted = true;
    }
}