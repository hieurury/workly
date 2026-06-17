/// Tất cả các chuỗi hiển thị trong ứng dụng (Tiếng Việt)
class AppStrings {
  AppStrings._();

  // === APP ===
  static const String appName = 'Workly';
  static const String appSlogan = 'Không có việc gì khó, chỉ sợ bạn mất streak.';

  // === NAVIGATION ===
  static const String navHome = 'Trang chủ';
  static const String navWork = 'Công việc';
  static const String navPrediction = 'Dự đoán';
  static const String navProfile = 'Cá nhân';

  // === ONBOARDING ===
  static const String onboardingWelcome = 'Chào mừng đến với Workly!';
  static const String onboardingSubtitle = 'Hãy thiết lập thông tin cá nhân để bắt đầu.';
  static const String onboardingName = 'Tên của bạn';
  static const String onboardingNameHint = 'Nhập tên của bạn...';
  static const String onboardingGender = 'Giới tính';
  static const String onboardingGenderMale = 'Nam';
  static const String onboardingGenderFemale = 'Nữ';
  static const String onboardingGenderOther = 'Khác';
  static const String onboardingAvatar = 'Ảnh đại diện';
  static const String onboardingCover = 'Ảnh bìa';
  static const String onboardingUploadPhoto = 'Tải ảnh lên';
  static const String onboardingSkip = 'Bỏ qua';
  static const String onboardingNext = 'Tiếp theo';
  static const String onboardingFinish = 'Bắt đầu ngay!';
  static const String onboardingStep1Title = 'Bạn là ai?';
  static const String onboardingStep2Title = 'Ảnh đại diện';
  static const String onboardingStep3Title = 'Ảnh bìa';

  // === HOME ===
  static const String homeGreetingMorning = 'Chào buổi sáng';
  static const String homeGreetingAfternoon = 'Chào buổi chiều';
  static const String homeGreetingEvening = 'Chào buổi tối';
  static const String homeStreakDays = 'ngày liên tiếp';
  static const String homeNoMainWork = 'Chưa có công việc nào';
  static const String homeAddWorkNow = 'Thêm công việc ngay';
  static const String homeDaysWorked = 'Ngày đã làm';
  static const String homeDaysOff = 'Ngày nghỉ';
  static const String homeEarned = 'Thu nhập';
  static const String homeWorkDays = 'Ngày công';
  static const String homeView7Days = '7 ngày';
  static const String homeView30Days = '30 ngày';
  static const String homeAttendanceButton = 'Điểm danh';
  static const String homeAttendancePending = 'còn lại';
  static const String homeTodayWorked = 'Đã điểm danh hôm nay';

  // === ATTENDANCE ===
  static const String attendanceTitle = 'Điểm danh hôm nay';
  static const String attendanceMakeup = 'Điểm danh bù';
  static const String attendanceSelectWork = 'Chọn công việc';
  static const String attendanceDayShift = 'Ca ngày';
  static const String attendanceNightShift = 'Ca đêm';
  static const String attendanceDayOff = 'Ngày nghỉ';
  static const String attendanceIsOvertime = 'Tăng ca';
  static const String attendanceStartTime = 'Giờ vào';
  static const String attendanceEndTime = 'Giờ ra';
  static const String attendanceCompensation = 'Đền bù ca';
  static const String attendanceNote = 'Ghi chú';
  static const String attendanceNotePlaceholder = 'Thêm ghi chú...';
  static const String attendanceConfirm = 'Xác nhận điểm danh';
  static const String attendanceSalaryReceived = 'Đã nhận lương';
  static const String attendanceConfirmSalary = 'Xác nhận nhận lương';

  // === WORK ===
  static const String workListTitle = 'Công việc';
  static const String workAddNew = 'Thêm công việc';
  static const String workNoData = 'Chưa có công việc nào.\nHãy thêm công việc đầu tiên!';
  static const String workFrozen = 'Đã đóng băng';
  static const String workActive = 'Đang hoạt động';
  static const String workMain = 'Công việc chính';
  static const String workSetMain = 'Đặt làm công việc chính';
  static const String workFreeze = 'Đóng băng';
  static const String workUnfreeze = 'Kích hoạt lại';
  static const String workDelete = 'Xoá công việc';
  static const String workDeleteConfirm = 'Bạn có chắc muốn xoá công việc này? Toàn bộ dữ liệu điểm danh sẽ bị mất.';
  static const String workEdit = 'Chỉnh sửa';
  static const String workDetailTitle = 'Chi tiết công việc';

  // === WORK FORM ===
  static const String workFormAddTitle = 'Thêm công việc';
  static const String workFormEditTitle = 'Chỉnh sửa công việc';
  static const String workFormStep1 = 'Thông tin cơ bản';
  static const String workFormStep2 = 'Cấu hình lương';
  static const String workFormStep3 = 'Thời gian làm việc';
  static const String workFormStep4 = 'Tỷ lệ tăng ca';
  static const String workFormStep5 = 'Trợ cấp & Thưởng';
  static const String workFormName = 'Tên công việc';
  static const String workFormNameHint = 'VD: Đi làm, Bán hàng...';
  static const String workFormDescription = 'Mô tả';
  static const String workFormDescriptionHint = 'Mô tả ngắn về công việc...';
  static const String workFormIcon = 'Chọn icon';
  static const String workFormColor = 'Chọn màu';
  static const String workFormIsMain = 'Đặt làm công việc chính';
  static const String workFormBaseSalary = 'Lương cơ bản (đ)';
  static const String workFormNumberOfDayWork = 'Số ngày công';
  static const String workFormNormalWorkTime = 'Giờ làm cơ bản';
  static const String workFormTimeToEat = 'Giờ nghỉ giữa ca';
  static const String workFormDayWorkTime = 'Ca ngày';
  static const String workFormNightWorkTime = 'Ca đêm';
  static const String workFormWeekend = 'Ngày cuối tuần';
  static const String workFormDayToSalary = 'Ngày nhận lương hàng tháng';
  static const String workFormDayToSalaryHint = 'VD: 15 (ngày 15 hàng tháng)';
  static const String workFormPercentDayOT = 'Tăng ca ngày';
  static const String workFormPercentNightOT = 'Tăng ca đêm';
  static const String workFormPercentWeekendDayOT = 'Tăng ca cuối tuần - Ngày';
  static const String workFormPercentWeekendNightOT = 'Tăng ca cuối tuần - Đêm';
  static const String workFormPercentHolidayDayOT = 'Tăng ca lễ - Ngày';
  static const String workFormPercentHolidayNightOT = 'Tăng ca lễ - Đêm';
  static const String workFormCompensationDay = 'Đền bù ca ngày (đ)';
  static const String workFormCompensationNight = 'Đền bù ca đêm (đ)';
  static const String workFormAddSubsidy = 'Thêm trợ cấp';
  static const String workFormSubsidyTitle = 'Tên trợ cấp';
  static const String workFormSubsidyValue = 'Giá trị (đ)';
  static const String workFormSave = 'Lưu';
  static const String workFormNext = 'Tiếp theo';
  static const String workFormBack = 'Quay lại';

  // === PREDICTION ===
  static const String predictionTitle = 'Dự đoán';
  static const String predictionSelectWork = 'Chọn công việc để phân tích';
  static const String predictionThisWeek = 'Tuần này';
  static const String predictionNextWeek = 'Tuần tới';
  static const String predictionThisMonth = 'Tháng này';
  static const String predictionAvgHourly = 'Lương TB/giờ';
  static const String predictionAvgDaily = 'Lương TB/ngày';
  static const String predictionIncomeChart = 'Thu nhập theo ngày';
  static const String predictionNoData = 'Chưa đủ dữ liệu để dự đoán.\nHãy điểm danh thêm vài ngày.';
  static const String predictionEstimated = 'Dự kiến';

  // === PROFILE ===
  static const String profileTitle = 'Cá nhân';
  static const String profileEdit = 'Chỉnh sửa hồ sơ';
  static const String profileSave = 'Lưu thay đổi';
  static const String profileName = 'Tên';
  static const String profileGender = 'Giới tính';
  static const String profileTheme = 'Giao diện';
  static const String profileThemeLight = 'Sáng';
  static const String profileThemeDark = 'Tối';
  static const String profileThemeSystem = 'Theo hệ thống';
  static const String profileLanguage = 'Ngôn ngữ';
  static const String profileLanguageVi = 'Tiếng Việt';
  static const String profileLanguageEn = 'English';
  static const String profileAppInfo = 'Thông tin ứng dụng';
  static const String profileVersion = 'Phiên bản';
  static const String profileDownloadDate = 'Ngày cài đặt';
  static const String profileTotalStreak = 'Streak hiện tại';
  static const String profileChangeAvatar = 'Đổi ảnh đại diện';
  static const String profileChangeCover = 'Đổi ảnh bìa';

  // === GENERAL ===
  static const String confirm = 'Xác nhận';
  static const String cancel = 'Huỷ';
  static const String delete = 'Xoá';
  static const String save = 'Lưu';
  static const String edit = 'Sửa';
  static const String close = 'Đóng';
  static const String back = 'Quay lại';
  static const String next = 'Tiếp theo';
  static const String done = 'Hoàn thành';
  static const String loading = 'Đang tải...';
  static const String error = 'Có lỗi xảy ra';
  static const String retry = 'Thử lại';
  static const String noData = 'Không có dữ liệu';
  static const String yes = 'Có';
  static const String no = 'Không';

  // === TIME ===
  static const String monday = 'Thứ 2';
  static const String tuesday = 'Thứ 3';
  static const String wednesday = 'Thứ 4';
  static const String thursday = 'Thứ 5';
  static const String friday = 'Thứ 6';
  static const String saturday = 'Thứ 7';
  static const String sunday = 'Chủ nhật';

  // === NOTIFICATION ===
  static const String notifTitle = 'Workly';
  static const String notifMorningBody = 'Đừng quên điểm danh ca ngày hôm nay! 🌅';
  static const String notifEveningBody = 'Đừng quên điểm danh ca tối hôm nay! 🌙';
  static const String notifChannelId = 'workly_attendance';
  static const String notifChannelName = 'Nhắc nhở điểm danh';
  static const String notifChannelDesc = 'Thông báo nhắc nhở điểm danh hàng ngày';

  // === SALARY DETAIL ===
  static const String salaryBase = 'Lương cơ bản';
  static const String salaryOvertime = 'Tăng ca';
  static const String salaryCompensation = 'Đền bù';
  static const String salarySubsidy = 'Trợ cấp';
  static const String salaryTotal = 'Tổng lương';
  static const String salaryPerHour = 'Lương/giờ';
  static const String salaryPerDay = 'Lương/ngày';

  // === CHART ===
  static const String chartPieTitle = 'Cơ cấu thu nhập';
  static const String chartLineTitle = 'Thu nhập tích lũy';

  // === ATTENDANCE STATUS ===
  static const String statusWorked = 'Đã làm';
  static const String statusOff = 'Nghỉ';
  static const String statusMissed = 'Quên điểm danh';
  static const String statusFuture = 'Chưa đến';
  static const String statusToday = 'Hôm nay';
}
