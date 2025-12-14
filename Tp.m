clear all;
clc;
format compact;

% 1. NHẬP DỮ LIỆU 
Cost = input('Nhập ma trận chi phí: ');
A = input('Cung: ');
B= input('Cầu: ');

% 2. KHỞI TẠO 
[m, n] = size(Cost);  % m = số hàng, n = số cột
sum_A = sum(A);
sum_B = sum(B);

if sum_A > sum_B % Cung > Cầu => Thêm CỘT giả (Cầu ảo)
    diff = sum_A - sum_B;
    fprintf('\n--> Thêm CỘT giả với cầu = %d, chi phí = 0\n', diff);
    Cost = [Cost, zeros(m, 1)]; % Thêm cột 0 vào bên phải Cost
    B = [B, diff];              % Thêm lượng cầu vào vector B
    n = n + 1;                  % Cập nhật số cột
    
elseif sum_B > sum_A % Cầu > Cung => Thêm HÀNG giả (Cung ảo)
    diff = sum_B - sum_A;
    fprintf('\n--> Thêm HÀNG giả với cung = %d, chi phí = 0\n', diff);
    Cost = [Cost; zeros(1, n)]; % Thêm hàng 0 vào dưới Cost
    A = [A, diff];              % Thêm lượng cung vào vector A
    m = m + 1;                  % Cập nhật số hàng
end
X = zeros(m, n);      % Ma trận kết quả (phân bổ)
ICost = Cost;         % Sao lưu ma trận chi phí gốc để tính tiền

% 3. TÌM PABĐ BẰNG GÓC TÂY BẮC 
A_temp = A; % Tạo bản sao Cung để NWC sử dụng
B_temp = B; % Tạo bản sao Cầu
i = 1; % Bắt đầu ở hàng 1
j = 1; % Bắt đầu ở cột 1
while (i <= m && j <= n)
    alloc_amount = min(A_temp(i), B_temp(j));
    X(i, j) = alloc_amount; % Gán vào ma trận kết quả
    A_temp(i) = A_temp(i) - alloc_amount;
    B_temp(j) = B_temp(j) - alloc_amount;
    
    if A_temp(i) < 1e-6 % Nếu Cung ở hàng i đã hết -> di chuyển XUỐNG
        i = i + 1;
    else % Nếu Cầu ở cột j đã hết -> di chuyển PHẢI
        j = j + 1;
    end
end
fprintf('\nBảng phân bổ:\n'); 
disp(X); 
InitialCost = sum(sum(ICost .* X)); % Tính tổng chi phí
fprintf('==> Tổng Chi Phí: %.2f\n', InitialCost);

% 5. GỌI HÀM MODI 
fprintf('\n[2] Phương Án Tối Ưu (từ MODI):\n');
% Gọi hàm modi (Hàm này được định nghĩa ở dưới)
[OptimalAllocation, OptimalCost] = modi(ICost, A, B, X, m, n); 
fprintf('Bảng phân bổ Tối Ưu:\n'); 
disp(OptimalAllocation); 
fprintf('==> Tổng Chi Phí Tối Ưu: %.2f\n', OptimalCost);


% HÀM PHỤ TRỢ (HELPER FUNCTIONS) 
function [Allocation, TotalCost] = modi(Costs, Supply, Demand, InitialAllocation, m, n)
    Allocation = InitialAllocation;
    iter = 1;
    while iter <= (m*n)
        % fprintf(' MODI: Lần lặp %d...\n', iter);
        % Bước 1: Xử lý suy biến (nếu cần)
        basic_cells = (Allocation > 1e-6);
        num_basics = sum(basic_cells(:));
        if num_basics < m + n - 1
            fprintf('Phát hiện suy biến! Thêm ô cơ sở 0 ảo.\n');
            non_basic_indices = find(Allocation <= 1e-6);
            [~, sort_idx] = sort(Costs(non_basic_indices));
            for k = 1:length(sort_idx)
                if num_basics >= m + n - 1
                    break;
                end
                idx_to_add = non_basic_indices(sort_idx(k));
                if ~basic_cells(idx_to_add)
                    basic_cells(idx_to_add) = 1;
                    num_basics = num_basics + 1;
                end
            end
        end
        % Bước 2: Tính u, v
        [r_basic, c_basic] = find(basic_cells);
        u = NaN(m, 1);
        v = NaN(1, n);
        u(1) = 0;
        for k = 1:(m + n)
            for i = 1:length(r_basic)
                r = r_basic(i);
                c = c_basic(i);
                if ~isnan(u(r)) && isnan(v(c))
                    v(c) = Costs(r, c) - u(r);
                elseif isnan(u(r)) && ~isnan(v(c))
                    u(r) = Costs(r, c) - v(c);
                end
            end
        end
        if any(isnan(u)) || any(isnan(v))
            u(isnan(u)) = 0;
            v(isnan(v)) = 0;
        end
        % Bước 3: Tính chi phí cơ hội & Kiểm tra tối ưu
        OppCosts = Inf(m, n);
        non_basic_cells_logical = (Allocation <= 1e-6) & ~basic_cells;
        non_basic_indices = find(non_basic_cells_logical);
        for idx = 1:length(non_basic_indices)
            r = mod(non_basic_indices(idx)-1, m) + 1;
            c = floor((non_basic_indices(idx)-1) / m) + 1;
            OppCosts(r, c) = Costs(r, c) - u(r) - v(c);
        end
        if all(OppCosts(:) >= -1e-6)
            fprintf('==> Đã đạt phương án TỐI ƯU.\n\n');
            break; % Đã tối ưu
        end
        % Bước 4: Tìm ô vào
        [min_delta, enter_idx] = min(OppCosts(:));
        [r_enter, c_enter] = ind2sub([m, n], enter_idx);
        fprintf('Lần lặp %d: Cải thiện ô (%d, %d), delta = %.2f\n', iter, r_enter, c_enter, min_delta);
        % Bước 5: Tìm vòng lặp (DFS)
        [loop_path, success] = find_loop(basic_cells, [r_enter, c_enter]);
        if ~success
            fprintf('Lỗi: Không tìm thấy vòng lặp. Dừng lại.\n');
            break;
        end
        % Bước 6: Tái phân bổ (Theta)
        minus_cells_idx = 2:2:size(loop_path, 1);
        minus_allocations = [];
        for i = 1:length(minus_cells_idx)
            r = loop_path(minus_cells_idx(i), 1);
            c = loop_path(minus_cells_idx(i), 2);
            minus_allocations = [minus_allocations, Allocation(r, c)];
        end
        theta = min(minus_allocations(minus_allocations > -1e-6));
        if isempty(theta)
            theta = 0;
        end
        for i = 1:size(loop_path, 1)
            r = loop_path(i, 1);
            c = loop_path(i, 2);
            if mod(i, 2) == 1
                Allocation(r, c) = Allocation(r, c) + theta;
            else
                Allocation(r, c) = Allocation(r, c) - theta;
            end
        end
        iter = iter + 1;
    end
    Allocation(Allocation < 1e-6) = 0;
    TotalCost = sum(sum(Allocation .* Costs));
end

% HÀM CON 3: TÌM VÒNG LẶP (DFS)
function [loop_path, success] = find_loop(basic_cells, start_node)
    % Hàm này tìm vòng lặp kín từ start_node, chỉ đi qua các ô basic_cells
    [r_start, c_start] = deal(start_node(1), start_node(2));
    search_cells = basic_cells;
    search_cells(r_start, c_start) = 1; % Thêm ô bắt đầu vào để tìm
    % Thử tìm theo cột trước
    [path_col, success_col] = search_path(search_cells, [r_start, c_start], 'col');
    if success_col
        loop_path = [r_start, c_start; path_col];
        success = true;
        return;
    end
    % Thử tìm theo hàng trước
    [path_row, success_row] = search_path(search_cells, [r_start, c_start], 'row');
    if success_row
        loop_path = [r_start, c_start; path_row];
        success = true;
        return;
    end
    loop_path = [];
    success = false;
end

function [path, success] = search_path(basic_cells, current_path_nodes, direction)
    % Hàm đệ quy DFS để tìm vòng lặp
    current_node = current_path_nodes(end, :);
    [r, c] = deal(current_node(1), current_node(2));
    start_node = current_path_nodes(1, :);
    [r_start, c_start] = deal(start_node(1), start_node(2));
    if strcmp(direction, 'col') % Tìm trong cột 'c'
        [m, ~] = size(basic_cells);
        possible_rows = find(basic_cells(:, c) & (1:m)' ~= r);
        for i = 1:length(possible_rows)
            new_r = possible_rows(i);
            % Kiểm tra đã quay lại hàng bắt đầu (và vòng lặp có ít nhất 4 ô)
            if new_r == r_start && size(current_path_nodes, 1) >= 3
                path = [new_r, c];
                success = true;
                return;
            end
            % Tránh quay lại ô vừa đi qua
            if size(current_path_nodes, 1) > 1 && all([new_r, c] == current_path_nodes(end-1, :))
                continue;
            end
            % Tiếp tục tìm kiếm (đổi hướng)
            [path_found, found] = search_path(basic_cells, [current_path_nodes; new_r, c], 'row');
            if found
                path = [new_r, c; path_found];
                success = true;
                return;
            end
        end
    else % Tìm trong hàng 'r'
        [~, n] = size(basic_cells);
        possible_cols = find(basic_cells(r, :) & (1:n) ~= c);
        for i = 1:length(possible_cols)
            new_c = possible_cols(i);
            % Kiểm tra đã quay lại cột bắt đầu
            if new_c == c_start && size(current_path_nodes, 1) >= 3
                path = [r, new_c];
                success = true;
                return;
            end
            % Tránh quay lại ô vừa đi qua
            if size(current_path_nodes, 1) > 1 && all([r, new_c] == current_path_nodes(end-1, :))
                continue;
            end
            % Tiếp tục tìm kiếm (đổi hướng)
            [path_found, found] = search_path(basic_cells, [current_path_nodes; r, new_c], 'col');
            if found
                path = [r, new_c; path_found];
                success = true;
                return;
            end
        end
    end
    % Không tìm thấy đường
    path = [];
    success = false;
end