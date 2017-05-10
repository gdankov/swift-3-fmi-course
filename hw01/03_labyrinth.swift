let STARTING_SYMBOL = "^"
let GOAL_SYMBOL = "*"
let WALL_SYMBOL = "1"
let AVAILABLE_POSITION = "0"

class Point : CustomStringConvertible{
    let x: Int
    let y: Int
    let parent: Point?

    var description: String {
        return "Point(\(x), \(y))"
    }

    init(x: Int, y: Int, parent: Point?) {
        self.x = x
        self.y = y
        self.parent = parent
    }
}

extension Point: Hashable {
    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

func findPath(in maze:[[String]]) -> [(Int, Int)]? {
    let pair = findStartAndGoalPoints(in: maze)
    if pair.start == nil || pair.goal == nil {
        return nil
    }

    let start = pair.start!
    let goal = pair.goal!

    let foundGoal = getGoal(in: maze, start: start, goal: goal)

    if foundGoal == nil {
        return nil
    }
    return getPath(from: foundGoal!)
}

func findStartAndGoalPoints(in maze: [[String]]) -> (start: Point?, goal: Point?) {
    var start: Point?
    var goal: Point?

    for row in 0..<maze.count {
        for column in 0..<maze[0].count {
            if start != nil && goal != nil {
                return (start, goal)
            }

            if isStartingPoint(maze[row][column]) {
                start = Point(x:row, y: column, parent:nil)
            } else if isGoalPoint(maze[row][column]) {
                goal = Point(x:row, y: column, parent:nil)
            }
        }
    }

    return (start, goal)
}

func isStartingPoint(_ element: String) -> Bool {
    return element == STARTING_SYMBOL
}

func isGoalPoint(_ element: String) -> Bool {
    return element == GOAL_SYMBOL
}

func getGoal(in maze: [[String]], start startPoint: Point, goal goalPoint: Point) -> Point? {
    var queue = [Point]()
    queue.append(startPoint)
    var visited = Set<Point>()
    while !queue.isEmpty {
        let current = queue.remove(at: 0)
        if current == goalPoint {
            return current
        }
        if !visited.contains(current) {
            visited.insert(current)

            for neighbour in getValidNeighbours(at:current, in:maze) {
                queue.append(neighbour)
            }
        }
    }
    return nil
}

func getValidNeighbours(at point: Point, in maze: [[String]]) -> [Point] {
    var validNeigbours = [Point]()
    for neighbour in getAllNeighbours(for:point) {
        if isValid(neighbour, in:maze) {
            validNeigbours.append(neighbour)
        }
    }

    return validNeigbours
}

func getAllNeighbours(for point: Point) -> [Point] {
    let x = point.x
    let y = point.y

    return [Point(x: x + 1, y: y, parent: point),
            Point(x: x - 1, y: y, parent: point),
            Point(x: x, y: y + 1, parent: point),
            Point(x: x, y: y-1, parent: point)]
}

func isValid(_ point: Point, in matrix: [[String]]) -> Bool {
    if point.x >= 0 && point.x < matrix.count &&
       point.y >= 0 && point.y < matrix[0].count {
           return matrix[point.x][point.y] != WALL_SYMBOL
    }
    return false
}


func getPath(from point: Point) -> [(Int, Int)] {
    var path = [(Int, Int)]()
    path.append((point.x, point.y))
    var current = point.parent
    while current != nil {
        path.append((current!.x, current!.y))
        current = current?.parent
    }
    return path.reversed()
}



var maze = [
    ["^", "0", "0", "0", "0", "0", "0", "1"],
    ["0", "1", "1", "1", "1", "1", "0", "0"],
    ["0", "0", "0", "0", "0", "1", "1", "1"],
    ["0", "1", "1", "1", "0", "1", "0", "0"],
    ["0", "1", "0", "1", "0", "0", "0", "1"],
    ["0", "0", "0", "1", "0", "1", "0", "*"]
]

var p = findPath(in:maze)
if let path = p {
    print(path)
} else {
    print("No path found in this maze!")
}
