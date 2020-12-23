import { range, tail } from "./common";

const cups = [9,4,2,3,8,7,6,1,5, ...range(10, 1000000)];

class LinkedListNode<T> {
    next: LinkedListNode<T>;

    constructor(public value: T) {
        this.next = this;
    }

    *iterator(): Generator<LinkedListNode<T>, LinkedListNode<T>> {
        let next = this.next;
        while (true) {
            yield next;
            next = next.next;
        }
    }

    takeNext(num: number): LinkedListNode<T>[] {
        const iterator = this.iterator();


        let lastTaken = iterator.next().value;
        const result = [lastTaken];
        for (let i = 1; i < num; i++) {
            lastTaken = iterator.next().value;   
            result.push(lastTaken);         
        }

        this.next = lastTaken.next;
        return result;
    }

    insert(node: LinkedListNode<T>) {
        node.next = this.next;
        this.next = node;

        return node;
    }

    insertMultiple(nodes: LinkedListNode<T>[]) {
        let node: LinkedListNode<T> = this;
        for (const v of nodes) {
            node = node.insert(v);
        }
    }

    find(value: T) {
        if (value === this.value) return this;
        let node: LinkedListNode<T> = this.next;
        while (node !== this) {
            if (value === node.value) return node;
            node = node.next;
        }
    }
}

class CircularLinkedList<T> {

    first: LinkedListNode<T>;

    constructor(items: T[]) {
        this.first = new LinkedListNode<T>(items[0]);
        let current = this.first;
        for (const item of tail(items)) {
            const node = new LinkedListNode(item);
            current = current.insert(node);
        }
    }

    *items() {
        yield this.first;
        const iter = this.first.iterator();
        let iterResult = iter.next();
        while (iterResult.value !== this.first) {
            yield iterResult.value;
            iterResult = iter.next();
        }
    }
}

function findDestination(currentValue: number, taken: number[], maxIndex: number) {
    let destination = currentValue - 1;
    if (destination === 0) destination = maxIndex;
    while (taken.includes(destination)) {
        destination--;
        if (destination === 0) destination = maxIndex;
    }
    return destination;
}

const list = new CircularLinkedList(cups);

const nodeMap = new Map([...list.items()].map(n => [n.value, n]));

let currentNode = list.first;
for (let i = 0; i < 10000000; i++) {
    // Take 3
    const taken = currentNode.takeNext(3);

    const destination = findDestination(currentNode.value, taken.map(n => n.value), cups.length);

    // Move to next current node
    currentNode = currentNode.next;

    // Find destination
    const destinationNode = nodeMap.get(destination)!;
    destinationNode.insertMultiple(taken);
}

const node1 = nodeMap.get(1)!;
console.log("Part 2:", node1.next.value, node1.next.next.value, node1.next.value * node1.next.next.value);
