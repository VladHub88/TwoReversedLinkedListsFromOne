
// Vladyslav Vovk test task

import XCTest

/**
Node of one-way-linked list
*/
class LinkedListNode<T>: Hashable {
    var value: T?
    var nextNode: LinkedListNode?
    
    init(value: T?) {
        self.value = value
    }
    
    static func ==(lhs: LinkedListNode<T>, rhs: LinkedListNode<T>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

/**
Modifies given one-way-linked list and returns two reversed one-way-linked lists containing odd (first linked list)
and even (second linked list) elements. Supports loops. O(n) time complexity.
- parameter headNode: head of the linked list
*/
func transformIntoTwoReversedLinkedLists<T>(headNode: LinkedListNode<T>?) -> [LinkedListNode<T>?] {

    // Dictionary with node indexes for linked list cycle detection.
    var indexesDictionary = [LinkedListNode<T>: Int]()

    var oddLinkedListHead: LinkedListNode<T>? = nil
    var evenLinkedListHead: LinkedListNode<T>? = nil
    
    var enumeratedNode: LinkedListNode? = headNode
    var enumeratedNodeIdx = 0
    
    while let unwrappedEnumeratedNode = enumeratedNode {
        indexesDictionary[unwrappedEnumeratedNode] = enumeratedNodeIdx
    
        let nextNode = unwrappedEnumeratedNode.nextNode
        
        if enumeratedNodeIdx.isEven {
            unwrappedEnumeratedNode.nextNode = evenLinkedListHead
            evenLinkedListHead = unwrappedEnumeratedNode
        } else {
            unwrappedEnumeratedNode.nextNode = oddLinkedListHead
            oddLinkedListHead = unwrappedEnumeratedNode
        }
        
        // If nextNodeIdx is NOT nil, we have a loop
        let nextNodeIdx = nextNode.flatMap{indexesDictionary[$0]}
        
        if let isNextNodeEven = nextNodeIdx.map({ $0.isEven }), isNextNodeEven != enumeratedNodeIdx.isEven {
            // Detected loop which we have to break since odd node loops to even node or vice versa.
            enumeratedNode = nil
        } else {
            // There's either no loop or loop which we don't have to break (odd loops to odd node or even loops to even node)
            enumeratedNode = nextNode
            enumeratedNodeIdx = nextNode.flatMap{indexesDictionary[$0]} ?? enumeratedNodeIdx + 1
        }
    }

    return [oddLinkedListHead, evenLinkedListHead]
}




///////////////////////////////////
// MARK - Tests

class LinkedListTransformationTests: XCTestCase {

    func testEmptyLinkedList() {
        let emptyLinkedList = generateEnumeratedLinkedList(numOfElements: 0)
        XCTAssertNil(emptyLinkedList)

        let reversedLinkedLists = transformIntoTwoReversedLinkedLists(headNode: emptyLinkedList)

        let oddLinkedList = reversedLinkedLists[safe: 0]?.flatMap{$0}
        XCTAssertNil(oddLinkedList)
        let evenLinkedList = reversedLinkedLists[safe: 1]?.flatMap{$0}
        XCTAssertNil(evenLinkedList)
    }

    func testOneElementLinkedList() {
        let oneElementLinkedList = generateEnumeratedLinkedList(numOfElements: 1)
        XCTAssertNotNil(oneElementLinkedList)

        let reversedLinkedLists = transformIntoTwoReversedLinkedLists(headNode: oneElementLinkedList)

        let oddLinkedList = reversedLinkedLists[safe: 0]?.flatMap{$0}
        XCTAssertNil(oddLinkedList)
        let evenLinkedList = reversedLinkedLists[safe: 1]?.flatMap{$0}
        XCTAssertEqual(evenLinkedList?.value, 0)
        XCTAssertNil(evenLinkedList?.nextNode)
    }

    func testTwoElementsLinkedList() {
        let twoElementsLinkedList = generateEnumeratedLinkedList(numOfElements: 2)
        XCTAssertNotNil(twoElementsLinkedList)

        let reversedLinkedLists = transformIntoTwoReversedLinkedLists(headNode: twoElementsLinkedList)
        let oddLinkedList = reversedLinkedLists[safe: 0]?.flatMap{$0}
        XCTAssertEqual(oddLinkedList?.value, 1)
        XCTAssertNil(oddLinkedList?.nextNode)
        let evenLinkedList = reversedLinkedLists[safe: 1]?.flatMap{$0}
        XCTAssertEqual(evenLinkedList?.value, 0)
        XCTAssertNil(evenLinkedList?.nextNode)
    }

    func testFiveElementsLinkedList() {
        let fiveElementsLinkedList = generateEnumeratedLinkedList(numOfElements: 5)
        XCTAssertNotNil(fiveElementsLinkedList)

        let reversedLinkedLists = transformIntoTwoReversedLinkedLists(headNode: fiveElementsLinkedList)
        let oddLinkedList = reversedLinkedLists[safe: 0]?.flatMap{$0}
        XCTAssertEqual(oddLinkedList?.value, 3)
        XCTAssertEqual(oddLinkedList?.nextNode?.value, 1)
        XCTAssertNil(oddLinkedList?.nextNode?.nextNode)
        let evenLinkedList = reversedLinkedLists[safe: 1]?.flatMap{$0}
        XCTAssertEqual(evenLinkedList?.value, 4)
        XCTAssertEqual(evenLinkedList?.nextNode?.value, 2)
        XCTAssertEqual(evenLinkedList?.nextNode?.nextNode?.value, 0)
        XCTAssertNil(evenLinkedList?.nextNode?.nextNode?.nextNode)
    }
    
    /**
    Test case when loop is created from element with odd idx to other element with odd idx.
    After transforming into two reversed linked lists, loop should be preserved.
    */
    func testLinkedListLoopPreserving() {
        let loopedLinkedList = generateEnumeratedLinkedList(numOfElements: 4)
        XCTAssertNotNil(loopedLinkedList)
        
        // Looping linked list. Node with idx 3 is now pointing to node with idx 1.
        loopedLinkedList?.nextNode?.nextNode?.nextNode?.nextNode = loopedLinkedList?.nextNode
        
        let reversedLinkedLists = transformIntoTwoReversedLinkedLists(headNode: loopedLinkedList)
        let oddLinkedList = reversedLinkedLists[safe: 0]?.flatMap{$0}
        XCTAssertEqual(oddLinkedList?.value, 1)
        XCTAssertEqual(oddLinkedList?.nextNode?.value, 3)
        XCTAssertEqual(oddLinkedList?.nextNode?.nextNode?.value, 1)
        XCTAssertEqual(oddLinkedList?.nextNode?.nextNode?.nextNode?.value, 3)
        XCTAssertEqual(oddLinkedList?.nextNode?.nextNode?.nextNode?.nextNode?.value, 1)
        let evenLinkedList = reversedLinkedLists[safe: 1]?.flatMap{$0}
        XCTAssertEqual(evenLinkedList?.value, 2)
        XCTAssertEqual(evenLinkedList?.nextNode?.value, 0)
        XCTAssertNil(evenLinkedList?.nextNode?.nextNode)
    }
    
    /**
    Test case when loop is created from element with odd idx to other element with even idx.
    After transforming into two reversed linked lists, loop should be removed.
    */
    func testLinkedListLoopBreaking() {
        let loopedLinkedList = generateEnumeratedLinkedList(numOfElements: 4)
        XCTAssertNotNil(loopedLinkedList)
        
        // Looping linked list. Node with idx 3 is now pointing to node with idx 2.
        loopedLinkedList?.nextNode?.nextNode?.nextNode?.nextNode = loopedLinkedList?.nextNode?.nextNode
        
        let reversedLinkedLists = transformIntoTwoReversedLinkedLists(headNode: loopedLinkedList)
        let oddLinkedList = reversedLinkedLists[safe: 0]?.flatMap{$0}
        XCTAssertEqual(oddLinkedList?.value, 3)
        XCTAssertEqual(oddLinkedList?.nextNode?.value, 1)
        XCTAssertNil(oddLinkedList?.nextNode?.nextNode)
        let evenLinkedList = reversedLinkedLists[safe: 1]?.flatMap{$0}
        XCTAssertEqual(evenLinkedList?.value, 2)
        XCTAssertEqual(evenLinkedList?.nextNode?.value, 0)
        XCTAssertNil(evenLinkedList?.nextNode?.nextNode)
    }
    
    /**
    Generates linked list with given number of elements.
    - parameter numOfElements: linked list length
    */
    private func generateEnumeratedLinkedList(numOfElements: Int) -> LinkedListNode<Int>? {
        guard numOfElements > 0 else {
            return nil
        }

        let linkedListHead = LinkedListNode(value: 0)
        var enumeratedLinkedListNode = linkedListHead

        for idx in 1..<numOfElements {
            let nextLinkedListNode = LinkedListNode(value: idx)
            enumeratedLinkedListNode.nextNode = nextLinkedListNode
            enumeratedLinkedListNode = nextLinkedListNode
        }
        
        return linkedListHead
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Int {
    var isEven: Bool {
        return self % 2 == 0
    }
}

LinkedListTransformationTests.defaultTestSuite.run()
