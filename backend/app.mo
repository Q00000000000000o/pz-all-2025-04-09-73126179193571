import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
//import Principal "mo:base/Principal";

actor {
  // 使用 stable 变量存储用户数据 (邮箱 -> 密码)
  stable var userEntries : [(Text, Text)] = [];
  var users = HashMap.HashMap<Text, Text>(10, Text.equal, Text.hash);

  // 系统初始化时恢复 stable 数据
  system func preupgrade() {
    userEntries := Iter.toArray(users.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Text, Text>(userEntries.vals(), 10, Text.equal, Text.hash);
    userEntries := [];
  };

  // 注册用户 (仅用于测试，实际应用中可能需要更安全的注册流程)
  public func register(username : Text, password : Text) : async Bool {
    if (Text.size(password) != 8) {
      return false; // 密码必须为 8 位
    };
    switch (users.get(username)) {
      case (?_) { return false; }; // 用户已存在
      case null {
        users.put(username, password);
        return true;
      };
    };
  };

  // 登录验证
  public shared func login(username : Text, password : Text) : async Text {
    switch (users.get(username)) {
      case (?storedPassword) {
        if (storedPassword == password) {
          return "https://pz1-all-beta-1-zres.4everland.app/"; // 验证通过返回跳转地址
        } else {
          return "wrong"; // 密码错误
        };
      };
      case null {
        return "wrong"; // 用户名不存在
      };
    };
  };
};