const std = @import("std");
const rl = @import("raylib");

var player_score: i32 = 0;
var cpu_score: i32 = 0;

const GREEN = rl.Color{
    .r = 38, // red
    .g = 185, // green
    .b = 154, // blue
    .a = 255, // alpha
};

const DARK_GREEN = rl.Color{
    .r = 20,
    .g = 160,
    .b = 133,
    .a = 255,
};

const LIGHT_GREEN = rl.Color{
    .r = 129,
    .g = 204,
    .b = 184,
    .a = 255,
};

const YELLOW = rl.Color{
    .r = 243,
    .g = 213,
    .b = 91,
    .a = 255,
};

const Timer = struct {
    life_time: f32,

    const Self = @This();

    fn start(self: *Self, life_time: f32) void {
        self.life_time = life_time;
    }

    fn update(self: *Self) void {
        if (self.life_time > 0) {
            self.life_time -= rl.getFrameTime();
        }
    }

    fn isDone(self: Self) bool {
        return self.life_time <= 0;
    }
};

const Ball = struct {
    x: i32,
    y: i32,
    radius: f32,
    speed_x: i32,
    speed_y: i32,
    timer: Timer,

    const Self = @This();

    fn init() Self {
        const timer = Timer{ .life_time = 0 };
        return Self{
            .x = @divTrunc(rl.getScreenWidth(), 2),
            .y = @divTrunc(rl.getScreenHeight(), 2),
            .radius = 20,
            .speed_x = 7,
            .speed_y = 7,
            .timer = timer,
        };
    }

    fn draw(self: Self) void {
        rl.drawCircle(self.x, self.y, self.radius, YELLOW);
    }

    fn update(self: *Self) void {
        self.x += self.speed_x;
        self.y += self.speed_y;

        if (self.y + @as(i32, @intFromFloat(self.radius)) >= rl.getScreenHeight() or self.y - @as(i32, @intFromFloat(self.radius)) <= 0) {
            self.speed_y *= -1;
        }

        if (self.x + @as(i32, @intFromFloat(self.radius)) >= rl.getScreenWidth()) {
            player_score += 1;
            self.reset();
        }
        if (self.x - @as(i32, @intFromFloat(self.radius)) <= 0) {
            cpu_score += 1;
            self.reset();
        }

        if (self.timer.isDone() and self.speed_x == 0 and self.speed_y == 0) {
            self.speed_x = 7;
            self.speed_y = 7;
            const speed_choices = [_]i8{ -1, 1 };
            self.speed_x *= speed_choices[@as(usize, @intCast(rl.getRandomValue(0, 1)))];
            self.speed_y *= speed_choices[@as(usize, @intCast(rl.getRandomValue(0, 1)))];
        } else {
            self.timer.update();
        }
    }

    fn reset(self: *Self) void {
        self.x = @divTrunc(rl.getScreenWidth(), 2);
        self.y = @divTrunc(rl.getScreenHeight(), 2);
        self.speed_x = 0;
        self.speed_y = 0;
        self.timer.start(1);
    }
};

const Paddle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,

    const Self = @This();

    fn draw(self: Self) void {
        const rec = rl.Rectangle{
            .x = self.x,
            .y = self.y,
            .width = self.width,
            .height = self.height,
        };
        rl.drawRectangleRounded(rec, 0.8, 0, rl.Color.white);
    }

    fn limitMovement(self: *Self) void {
        if (self.y <= 0) {
            self.y = 0;
        }

        if (self.y + self.height >= @as(f32, @floatFromInt(rl.getScreenHeight()))) {
            self.y = @as(f32, @floatFromInt(rl.getScreenHeight())) - self.height;
        }
    }
};

const PlayerPaddle = struct {
    paddle: Paddle,

    const Self = @This();

    fn init() Self {
        var paddle = Paddle{
            .x = 0,
            .y = 0,
            .width = 25,
            .height = 120,
            .speed = 6,
        };
        paddle.x = 10;
        paddle.y = @as(f32, @floatFromInt(@divTrunc(rl.getScreenHeight(), 2))) - paddle.height / 2;

        return Self{
            .paddle = paddle,
        };
    }

    fn draw(self: Self) void {
        self.paddle.draw();
    }

    fn update(self: *Self) void {
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            self.paddle.y -= self.paddle.speed;
        } else if (rl.isKeyDown(rl.KeyboardKey.down)) {
            self.paddle.y += self.paddle.speed;
        }
        self.paddle.limitMovement();
    }
};

const CPUPaddle = struct {
    paddle: Paddle,

    const Self = @This();

    fn init() Self {
        var paddle = Paddle{
            .x = 0,
            .y = 0,
            .width = 25,
            .height = 120,
            .speed = 6,
        };
        paddle.x = @as(f32, @floatFromInt(rl.getScreenWidth())) - paddle.width - 10;
        paddle.y = @as(f32, @floatFromInt(@divTrunc(rl.getScreenHeight(), 2))) - paddle.height / 2;

        return Self{
            .paddle = paddle,
        };
    }

    fn draw(self: Self) void {
        self.paddle.draw();
    }

    fn update(self: *Self, _ball_y: i32) void {
        const ball_y = @as(f32, @floatFromInt(_ball_y));
        if (self.paddle.y + @divTrunc(self.paddle.height, 2) > ball_y) {
            self.paddle.y -= self.paddle.speed;
        }

        if (self.paddle.y + @divTrunc(self.paddle.height, 2) <= ball_y) {
            self.paddle.y += self.paddle.speed;
        }

        self.paddle.limitMovement();
    }
};

pub fn main() anyerror!void {
    const screen_width: i32 = 1280;
    const screen_height: i32 = 800;
    rl.initWindow(screen_width, screen_height, "Zig Pong");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var ball = Ball.init();
    var player = PlayerPaddle.init();
    var cpu = CPUPaddle.init();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Updating
        ball.update();
        player.update();
        cpu.update(ball.y);

        // Checking for collisions
        const ball_vec = rl.Vector2{ .x = @as(f32, @floatFromInt(ball.x)), .y = @as(f32, @floatFromInt(ball.y)) };
        const player_rec = rl.Rectangle{ .x = player.paddle.x, .y = player.paddle.y, .width = player.paddle.width, .height = player.paddle.height };
        if (rl.checkCollisionCircleRec(ball_vec, ball.radius, player_rec)) {
            ball.speed_x *= -1;
        }

        const cpu_rec = rl.Rectangle{ .x = cpu.paddle.x, .y = cpu.paddle.y, .width = cpu.paddle.width, .height = cpu.paddle.height };
        if (rl.checkCollisionCircleRec(ball_vec, ball.radius, cpu_rec)) {
            ball.speed_x *= -1;
        }

        // Drawing
        rl.clearBackground(DARK_GREEN);
        rl.drawRectangle(@divTrunc(rl.getScreenWidth(), 2), 0, @divTrunc(rl.getScreenWidth(), 2), rl.getScreenHeight(), GREEN);
        rl.drawCircle(@divTrunc(rl.getScreenWidth(), 2), @divTrunc(rl.getScreenHeight(), 2), 150, LIGHT_GREEN);
        rl.drawLine(@divTrunc(rl.getScreenWidth(), 2), 0, @divTrunc(rl.getScreenWidth(), 2), rl.getScreenHeight(), rl.Color.white);
        rl.drawText(rl.textFormat("%i", .{player_score}), @divTrunc(rl.getScreenWidth(), 4) - 20, 20, 80, rl.Color.white);
        rl.drawText(rl.textFormat("%i", .{cpu_score}), 3 * @divTrunc(rl.getScreenWidth(), 4) - 20, 20, 80, rl.Color.white);

        ball.draw();
        player.draw();
        cpu.draw();
    }
}
