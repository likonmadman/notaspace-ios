//
//  AppCountryCodePicker.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Структура для кода страны
struct CountryCode: Identifiable, Codable {
    let id: String
    let value: String
    let label: String
    let description: String
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case value, label, description, icon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        label = try container.decode(String.self, forKey: .label)
        description = try container.decode(String.self, forKey: .description)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        id = value
    }
}

/// Компонент выбора кода страны
struct AppCountryCodePicker: View {
    @Binding var selectedCode: String
    @State private var isOpen = false
    @State private var countryCodes: [CountryCode] = []
    @State private var isLoading = false
    @State private var searchQuery = ""
    @State private var errorMessage: String?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Кнопка выбора
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOpen.toggle()
            }
            if countryCodes.isEmpty && !isLoading {
                loadCountryCodes()
            }
        }) {
            HStack {
                if let selected = selectedCountry {
                    Text(selected.label)
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                } else {
                    Text("+7")
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                }
                
                Spacer()
                
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(width: 100, height: 48) // Фиксируем размер кнопки
            .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isOpen 
                            ? AppColors.primary 
                            : (colorScheme == .dark ? AppColors.Dark.border : AppColors.border),
                        lineWidth: 1
                    )
            )
            .cornerRadius(12)
            .overlay(alignment: .topLeading) {
                // Выпадающий список - абсолютно позиционирован через overlay (не влияет на layout)
                if isOpen {
                VStack(spacing: 0) {
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        
                        TextField("Поиск...", text: $searchQuery)
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                        
                        if !searchQuery.isEmpty {
                            Button(action: {
                                searchQuery = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.border : AppColors.border),
                        alignment: .bottom
                    )
                    
                    // Список стран
                    ScrollView {
                        VStack(spacing: 0) {
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            } else if filteredCountries.isEmpty {
                                Text("Ничего не найдено")
                                    .font(.system(size: 14))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                    .padding()
                            } else {
                                ForEach(filteredCountries) { country in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCode = country.value
                                            isOpen = false
                                            searchQuery = ""
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            // Флаг (если есть URL, можно загрузить через AsyncImage)
                                            if let icon = country.icon, !icon.isEmpty {
                                                AsyncImage(url: URL(string: icon)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.3))
                                                }
                                                .frame(width: 24, height: 18)
                                                .cornerRadius(2)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(country.label)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(
                                                        selectedCode == country.value
                                                            ? AppColors.secondaryText
                                                            : (colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                                    )
                                                
                                                Text(country.description)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(
                                                        selectedCode == country.value
                                                            ? AppColors.secondaryText.opacity(0.8)
                                                            : (colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                                    )
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedCode == country.value {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(AppColors.secondaryText)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedCode == country.value
                                                ? AppColors.primary
                                                : Color.clear
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if country.id != filteredCountries.last?.id {
                                        Divider()
                                            .background(colorScheme == .dark ? AppColors.Dark.border : AppColors.border)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                }
                .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? AppColors.Dark.border : AppColors.border, lineWidth: 1)
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .offset(x: 0, y: 56) // Смещаем вниз от кнопки (высота кнопки ~48px + небольшой отступ)
                .frame(width: 200) // Фиксированная ширина для выпадающего списка
                .allowsHitTesting(true) // Разрешаем взаимодействие с выпадающим списком
                }
            }
        }
        .frame(width: 100, height: 48) // Фиксируем размер контейнера (только кнопка)
        .zIndex(isOpen ? 1000 : 0)
        .onAppear {
            if countryCodes.isEmpty {
                loadCountryCodes()
            }
        }
    }
    
    private var selectedCountry: CountryCode? {
        countryCodes.first { $0.value == selectedCode }
    }
    
    private var filteredCountries: [CountryCode] {
        if searchQuery.isEmpty {
            return countryCodes
        }
        let query = searchQuery.lowercased()
        return countryCodes.filter {
            $0.label.lowercased().contains(query) ||
            $0.description.lowercased().contains(query)
        }
    }
    
    private func loadCountryCodes() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        // Используем явное указание типа для избежания конфликта с моделью Task
        let asyncTask = _Concurrency.Task<Void, Never> {
            do {
                // API возвращает структуру { data: [...] }
                struct CountryCodesResponse: Codable {
                    let data: [CountryCode]
                }
                
                let response: CountryCodesResponse = try await APIClient.shared.request(
                    endpoint: "/get-country-codes",
                    method: .get
                )
                
                await MainActor.run {
                    countryCodes = response.data
                    isLoading = false
                    
                    // Если выбранный код не найден, устанавливаем +7 по умолчанию
                    if !countryCodes.contains(where: { $0.value == selectedCode }) {
                        if let defaultCode = countryCodes.first(where: { $0.value == "+7" }) {
                            selectedCode = defaultCode.value
                        } else if let first = countryCodes.first {
                            selectedCode = first.value
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Не удалось загрузить коды стран"
                    // Устанавливаем +7 по умолчанию при ошибке
                    if selectedCode.isEmpty {
                        selectedCode = "+7"
                    }
                }
            }
        }
        _ = asyncTask // Сохраняем ссылку на задачу
    }
}

#Preview {
    AppCountryCodePicker(selectedCode: .constant("+7"))
        .padding()
}

